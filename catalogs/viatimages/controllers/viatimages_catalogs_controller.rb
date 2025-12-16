class ViatimagesCatalogsController < CatalogsController
  include AdvancedSearchConfig

  def show
    image_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'images')

    # Retrieve & sort the all the corpuses
    corpus_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'corpus')
    corpus_field = image_type.first.find_field('corpus')
    corpus_type_items = corpus_type.empty? ? [] : Item.where(item_type_id: corpus_type.ids.first).sorted_by_field(corpus_type.first.find_field('titre'))
    @corpus_type_items = {}
    corpus_type_items.each do |corpus|
      @corpus_type_items.store(
        corpus,
        {
          :link => [I18n.locale, "images?corpus=#{corpus.id}"].join("/"),
          :count => image_type.first.items.where(
            "data->>'#{corpus_field.uuid}' = ?", corpus.id.to_s
          ).count
        }
      )
    end

    # Retrieve & sort the all the domains
    domain_choice_set = ChoiceSet.where(catalog_id: @catalog.id).where(name: 'Domaines')
    domain_field = image_type.first.find_field('domaine')
    domain_choice_set_items = domain_choice_set.empty? ? [] : Choice.where(choice_set_id: domain_choice_set.ids.first).sorted
    @domain_choice_set_items = {}
    domain_choice_set_items.each do |domain|
      @domain_choice_set_items.store(
        domain,
        {
          :link => [I18n.locale, "images?domaine=#{domain.id}"].join("/"),
          :count => image_type.first.items.where(
            "(data->>'#{domain_field.uuid}')::jsonb @> ?", "[\"#{domain.id}\"]"
          ).count
        }
      )
    end

    # Retrieve the first 20 most used keywords
    # Make a single raw SQL query to avoid 20+ queries
    image_type_keyword_field = image_type.present? ? image_type.first.find_field('mot-cle') : nil
    keywords_attribute = image_type_keyword_field.uuid
    keyword_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'keywords').first
    keyword_name_field = keyword_type.find_field('mot').uuid

    keywords = ActiveRecord::Base.connection.execute("
      SELECT
        A.kid AS id,
        (I.data ->> '#{keyword_name_field}')::jsonb->'_translations'->>'#{I18n.locale}' AS keyword,
        n
      FROM items I
      JOIN (
        WITH keyword_ids AS (
          SELECT jsonb_array_elements_text((data ->> '#{keywords_attribute}')::jsonb)::int AS kid
          FROM items
          WHERE data -> '#{keywords_attribute}' IS NOT NULL
        )
        SELECT kid, COUNT(*) AS n
        FROM keyword_ids
        GROUP BY kid
        LIMIT 20
      ) A ON I.id = A.kid
      ORDER BY n DESC")

    @keywords = []
    keyword_size_classes = %w[largest large medium small]
    keywords.each_with_index do |kw, idx|
      @keywords.push("id" => kw['id'], "name" => kw['keyword'], "size" => keyword_size_classes[idx / 5])
    end
    @keywords.sort_by! { |v| v['name'] }
    @keywords_base_url = [I18n.locale, "keywords"].join("/")

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end
end
