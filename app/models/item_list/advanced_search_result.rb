# Wraps the AdvancedSearch ActiveRecord model with all the actual logic for
# performing the search and paginating the results.
#
class ItemList::AdvancedSearchResult < ItemList
  include ::Search::Strategies

  attr_reader :model

  delegate :catalog, :item_type, :criteria, :locale, :to_param, :to => :model
  delegate :fields, :to => :item_type

  def initialize(model:, page:nil, per:nil)
    super(model.catalog, page, per)
    @model = model
  end

  def permit_criteria(params)
    permitted = {}
    strategies.each do |strategy|
      permitted[strategy.field.uuid] = strategy.permitted_keys
    end
    params.permit(:criteria => permitted)
  end

  def items_as_geojson(advanced_search_config)
    features = []

    fields = advanced_search_config.geo_fields_as_fields

    # Get all geo fields if none are selected.
    fields = @model.fields.where(type: 'Field::Geometry') if fields.empty?

    fields.each do |field|
      geometry_aware_items = unpaginaged_items.reject { |it| it.data[field.uuid].blank? }

      features.concat(
        geometry_aware_items.map do |item|
          next if item.data[field.uuid]["features"].blank?

          item.data[field.uuid]["features"].each_with_index do |_feat, i|
            item.data[field.uuid]["features"][i]["properties"]["id"] = item.id
            item.data[field.uuid]["features"][i]["properties"]["polygon_color"] = field.polygon_color
            item.data[field.uuid]["features"][i]["properties"]["polyline_color"] = field.polyline_color
            item.data[field.uuid]["features"]
          end
        end
      )
    end

    features
  end

  private

  def unpaginaged_items
    original_scope = item_type.public_sorted_items.select("items.id")

    return original_scope.unscope(:select) if criteria.blank?

    items_strategies = build_items_strategies(original_scope)

    and_relations = merge_relations(items_strategies["and"], original_scope)
    or_relations = or_relations(items_strategies["or"], original_scope)
    exclude_relations = merge_relations(items_strategies["exclude"], original_scope)

    and_relations = and_relations.merge(exclude_relations) if items_strategies["exclude"].present?

    if items_strategies["or"].present?
      return items_in("#{and_relations.unscope(:order).to_sql} UNION #{or_relations}") if items_strategies["and"].present?

      return items_in(or_relations)
    end

    items_in(and_relations.to_sql)
  end

  def build_items_strategies(scope)
    items_strategies = {
      "and" => [],
      "or" => [],
      "exclude" => []
    }

    strategies.each do |strategy|
      criteria = field_criteria(strategy.field)

      # The first strategy doesn't have and/or/exclude field in the view, so we manually add it here
      criteria[:field_condition] = "and" if criteria[:field_condition].blank?

      next if empty_search_criteria(criteria)

      # Simple fields
      build_simple_fields_relations(items_strategies, strategy, criteria, scope)

      # React complex fields that can have multiple values
      next if criteria["0"].blank?

      build_complex_fields_relations(items_strategies, strategy, criteria, scope)
    end

    items_strategies
  end

  def build_simple_fields_relations(items_strategies, strategy, criteria, scope)
    return unless %w[or exclude and].include?(criteria[:field_condition]) && criteria["0"].blank?

    items_strategies[criteria[:field_condition]] << strategy.search(scope, criteria)
  end

  def build_complex_fields_relations(items_strategies, strategy, criteria, scope)
    # Remove previously added criteria[:field_condition]
    criteria = criteria.except(:field_condition)

    if strategy.field.is_a?(Field::ComplexDatation)
      criteria = criteria.select do |_k, v|
        start_or_end_date_present = (v[:start].present? && v[:start][v[:start].keys.first].present?) || (v[:end].present? && v[:end][v[:end].keys.first].present?)
        (v[:default]&.length != 0) || (start_or_end_date_present && (v[:start][v[:start].keys.first].each do |_key, value|
                                                                       value.present?
                                                                     end && v[:end][v[:end].keys.first].each do |_key, value|
                                                                              value.present?
                                                                            end))
      end
    end

    criteria.each_key do |key|
      criteria[key][:field_condition] = "and" if criteria[key][:field_condition].blank?

      next unless %w[or exclude and].include?(criteria[key][:field_condition])

      items_strategies[criteria[key][:field_condition]] << strategy.search(scope, criteria[key])
    end
  end

  def merge_relations(strategies, original_scope)
    return original_scope unless strategies.count.positive?

    relations = strategies.first
    strategies.drop(1).each do |relation|
      # Needed for reference filter search
      relation = relation.unscope(where: :item_type_id) if relations.to_sql.include?("parent_items")
      relations = relations.merge(relation)
    end

    relations
  end

  def or_relations(strategies, original_scope)
    return original_scope unless strategies.count.positive?

    rel = ""
    strategies.map do |relation|
      select_name = relation.to_sql.include?("parent_items") ? "parent_items" : "items"
      rel << " " << relation.unscope(:select).unscope(:order).select("#{select_name}.id").to_sql
      rel << " UNION "
    end

    rel.chomp(" UNION ")
  end

  def field_criteria(field)
    (criteria || {}).fetch(field.uuid, {}).with_indifferent_access
  end

  def empty_search_criteria(criteria)
    criteria.except(:field_condition, :condition).each do |_, value|
      if value.is_a?(Hash)
        return false unless empty_search_criteria(value)
      elsif value.present?
        return false
      end
    end

    true
  end

  def items_in(relations)
    Item.where("(items.id) IN (#{relations})")
  end
end
