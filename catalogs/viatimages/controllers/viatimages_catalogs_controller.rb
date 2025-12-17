class ViatimagesCatalogsController < CatalogsController
  include AdvancedSearchConfig

  def show
    homepage_data = build_homepage_data

    @corpus_type_items = homepage_data[:corpus_type_items]
    @domain_choice_set_items = homepage_data[:domain_choice_set_items]
    @keywords = homepage_data[:keywords]
    @keywords_base_url = homepage_data[:keywords_base_url]

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end

  private

  def build_homepage_data
    image_type = ItemType.where(catalog_id: @catalog.id, slug: 'images').first
    return default_empty_data unless image_type

    {
      corpus_type_items: build_corpus_data(image_type),
      domain_choice_set_items: build_domain_data(image_type),
      keywords: build_keywords_data(image_type),
      keywords_base_url: [I18n.locale, "keywords"].join("/")
    }
  end

  def build_corpus_data(image_type)
    corpus_type = ItemType.where(catalog_id: @catalog.id, slug: 'corpus').first
    return {} unless corpus_type

    corpus_field = image_type.find_field('corpus')
    return {} unless corpus_field

    titre_field = corpus_type.find_field('titre')

    # Single optimized query with COUNT using GROUP BY
    corpus_counts = Item.where(item_type_id: image_type.id)
                        .where("data->>'#{corpus_field.uuid}' IS NOT NULL")
                        .group("data->>'#{corpus_field.uuid}'")
                        .count

    # Get all corpus items at once
    corpus_items = Item.where(item_type_id: corpus_type.id)
                       .sorted_by_field(titre_field)

    corpus_type_items = {}
    corpus_items.each do |corpus|
      corpus_type_items[corpus] = {
        link: [I18n.locale, "images?corpus=#{corpus.id}"].join("/"),
        count: corpus_counts[corpus.id.to_s] || 0
      }
    end

    corpus_type_items
  end

  def build_domain_data(image_type)
    domain_choice_set = ChoiceSet.where(catalog_id: @catalog.id, name: 'Domaines').first
    return {} unless domain_choice_set

    domain_field = image_type.find_field('domaine')
    return {} unless domain_field

    # Single optimized query to count domains
    # Using LATERAL join to unnest the JSON array
    domain_counts = ActiveRecord::Base.connection.execute("
      SELECT
        domain_id::int AS id,
        COUNT(*) AS count
      FROM items,
      LATERAL jsonb_array_elements_text((data->>'#{domain_field.uuid}')::jsonb) AS domain_id
      WHERE item_type_id = #{image_type.id}
        AND data->>'#{domain_field.uuid}' IS NOT NULL
      GROUP BY domain_id
    ").to_a.each_with_object({}) { |row, hash| hash[row['id']] = row['count'] }

    # Get all domain choices at once
    domain_choices = Choice.where(choice_set_id: domain_choice_set.id).sorted

    domain_choice_set_items = {}
    domain_choices.each do |domain|
      domain_choice_set_items[domain] = {
        link: [I18n.locale, "images?domaine=#{domain.id}"].join("/"),
        count: domain_counts[domain.id] || 0
      }
    end

    domain_choice_set_items
  end

  def build_keywords_data(image_type)
    keyword_field = image_type.find_field('mot-cle')
    return [] unless keyword_field

    keyword_type = ItemType.where(catalog_id: @catalog.id, slug: 'keywords').first
    return [] unless keyword_type

    keyword_name_field = keyword_type.find_field('mot')
    return [] unless keyword_name_field

    # Optimized single query with proper filtering on item_type_id
    keywords = ActiveRecord::Base.connection.execute("
      SELECT
        A.kid AS id,
        (I.data ->> '#{keyword_name_field.uuid}')::jsonb->'_translations'->>'#{I18n.locale}' AS keyword,
        n
      FROM items I
      JOIN (
        WITH keyword_ids AS (
          SELECT jsonb_array_elements_text((data ->> '#{keyword_field.uuid}')::jsonb)::int AS kid
          FROM items
          WHERE item_type_id = #{image_type.id}
            AND data -> '#{keyword_field.uuid}' IS NOT NULL
        )
        SELECT kid, COUNT(*) AS n
        FROM keyword_ids
        GROUP BY kid
        ORDER BY n DESC
        LIMIT 20
      ) A ON I.id = A.kid
    ")

    keyword_size_classes = %w[largest large medium small]
    result = []
    keywords.each_with_index do |kw, idx|
      result.push({
                    "id" => kw['id'],
                    "name" => kw['keyword'],
                    "size" => keyword_size_classes[idx / 5]
                  })
    end
    result.sort_by! { |v| v['name'] }
    result
  end

  def default_empty_data
    {
      corpus_type_items: {},
      domain_choice_set_items: {},
      keywords: [],
      keywords_base_url: [I18n.locale, "keywords"].join("/")
    }
  end
end
