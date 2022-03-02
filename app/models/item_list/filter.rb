class ItemList::Filter < ItemList
  # This is the inverse of the to_param method, below.
  def self.parse_param(param)
    field_slug, value = param.to_s.split("_", 2)
    field_slug.present? ? {field_slug: field_slug, :value => value} : {}
  end

  include ::Search::Strategies

  attr_reader :item_type, :field, :value, :sort_field, :sort

  delegate :fields, :to => :item_type
  delegate :locale, :to => I18n

  def initialize(item_type:, field: nil, value: nil, page: nil, per: nil, sort_field: false, sort: 'ASC')
    super(item_type.catalog, page, per)
    @item_type = item_type
    @field = field
    @value = value
    @sort_field = sort_field || @item_type.field_for_select
    @sort = sort
  end

  def unpaginaged_items
    scope = item_type.public_sorted_items
    return scope if strategy.nil?

    strategy.browse(scope, value)
  end

  def items
    super

    field_to_sort_by = sort_field || item_type.field_for_select
    return sort_unpaginated_items(field_to_sort_by) if field_to_sort_by

    unpaginated_list_items
  end

  def to_param
    return nil if strategy.nil?

    [field.slug, value].join("_")
  end

  private

  def sort_unpaginated_items(field)
    direction = sort || 'ASC'
    case field
    when Field::Reference
      unpaginated_list_items.joins("LEFT JOIN items sort_ref_items ON sort_ref_items.id::text = items.data->>'#{field.uuid}'")
                            .reorder(Arel.sql("NULLIF(sort_ref_items.data->>'#{field.related_item_type.field_for_select.uuid}', '') ASC NULLS LAST,
                                                      (sort_ref_items.data->>'#{field.related_item_type.field_for_select.uuid}') #{direction}")) unless field.related_item_type.field_for_select.nil?
    when Field::ChoiceSet
      unpaginated_list_items.joins("LEFT JOIN choices sort_choices ON sort_choices.id::text = items.data->>'#{sort_field.uuid}'")
                            .reorder(Arel.sql("NULLIF(sort_choices.short_name_translations->>'short_name_#{I18n.locale}', '') ASC NULLS LAST,
                                                      (sort_choices.short_name_translations->>'short_name_#{I18n.locale}') #{direction}")) unless field.choices.nil?
    when Field::DateTime
      unpaginated_list_items.reorder(
        Arel.sql(
          "COALESCE( NULLIF(items.data->'#{field.uuid}'->>'Y', ''),
                            NULLIF(items.data->'#{field.uuid}'->>'M', ''),
                            NULLIF(items.data->'#{field.uuid}'->>'D', ''),
                            NULLIF(items.data->'#{field.uuid}'->>'h', ''),
                            NULLIF(items.data->'#{field.uuid}'->>'m', ''),
                            NULLIF(items.data->'#{field.uuid}'->>'s', '')
                  ) ASC,
                  NULLIF(items.data->'#{field.uuid}'->>'#{field.format[0]}', '')::bigint ASC,
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'Y', '')::bigint, 0) * 60 * 60 * 24 * (365 / 12) * 12 ) +
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'M', '')::bigint, 0) * 60 * 60 * 24 * (365 / 12) ) +
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'D', '')::bigint, 0) * 60 * 60 * 24 ) +
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'h', '')::bigint, 0) * 60 * 60 ) +
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'m', '')::bigint, 0) * 60 ) +
                  (COALESCE(NULLIF(items.data->'#{field.uuid}'->>'s', '')::bigint, 0) ) #{direction}"
        )
      )
    else
      unpaginated_list_items.reorder(
        Arel.sql("NULLIF(items.data->>'#{field.uuid}', '') ASC, items.data->>'#{field.uuid}' #{direction}")
      )
    end
  end

  def strategy
    strategies.find { |s| s.field == field }
  end
end
