class Search::ReferenceStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch

  permit_criteria :exact, :all_words, :one_word, :less_than, :less_than_or_equal_to, :greater_than,
                  :greater_than_or_equal_to, :field_condition, :filter_field_uuid, :condition, :default,
                  :start => {}, :end => {}

  def keywords_for_index(item)
    primary_text_for_keywords(item)
  end

  def search(scope, criteria)
    negate = criteria[:field_condition] == "exclude"

    # User searched by tag
    if criteria[:default].present?
      criterias = criteria[:default].split(',')

      criteria[:default] = []
      criterias.each do |c|
        criteria[:default] << c
      end

      scope = search_data_matching_all(scope, criteria[:default], negate)
    end

    scope = search_in_ref_field(scope, criteria) if criteria[:filter_field_uuid].present?

    scope
  end

  def browse(scope, item_id)
    search_data_matching_one_or_more(scope, item_id)
  end

  private

  def primary_text_for_keywords(item)
    ids = raw_value(item)
    return if ids.blank?

    ids = [ids] unless ids.is_a?(Array)
    ids.each_with_object([]) do |key, array|
      item = Item.find_by(id: key)
      array << item.default_display_name(locale) if item
    end
  end

  def search_in_ref_field(scope, criteria)
    ref_field = Field.find_by(uuid: criteria[:filter_field_uuid])
    return scope if ref_field.nil?

    klass = "Search::#{ref_field.type.sub(/^Field::/, '')}Strategy"
    strategy = klass.constantize.new(ref_field, locale)
    strategy.sql_select_name = "items"

    scope = if field.multiple?
              strategy.search(
                scope.select('"parent_items".*')
                  .from("items parent_items")
                  .joins("LEFT JOIN items ON (parent_items.data->>'#{field.uuid}')::jsonb ?| array[items.id::text] AND parent_items.item_type_id = #{field.item_type.id}"),
                criteria)
            else
              strategy.search(
                scope.unscope(where: :item_type_id)
                  .select('"parent_items".*')
                  .from("items parent_items")
                  .joins("LEFT JOIN items ON parent_items.data->>'#{field.uuid}' = items.id::text AND parent_items.item_type_id = #{field.item_type.id}"),
                criteria)
            end

    scope
  end
end
