# Wraps the AdvancedSearch ActiveRecord model with all the actual logic for
# performing the search and paginating the results.
#
class ItemList::AdvancedSearchResult < ItemList
  include Search::Strategies
  include ItemMapsHelper

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

  # Uses the first Geometry Field found among the advanced_search's fields
  def items_as_geojson
    @model.fields.each do |field|
      next unless field.type_name == "Geometry"

      return items.reject { |it| it.data[field.uuid].blank? }.map do |item|
        # TODO: part 3 : display only fields that have been selected to be displayed in the advanced search configuration
        popup_content = ApplicationController.render(
          :partial => 'advanced_searches/popup_content',
          :assigns => {
            :item => item,
            :field => field
          }
        )

        if item.data[field.uuid].present?
          item.data[field.uuid]["features"][0]["properties"]["popupContent"] = popup_content
          item.data[field.uuid]["features"][0]
        end
      end
    end
  end

  private

  def unpaginaged_items
    original_scope = item_type.public_sorted_items

    return original_scope if criteria.blank?

    items_strategies = build_items_strategies(original_scope)

    and_relations = merge_relations(items_strategies["and"], original_scope)
    or_relations = or_relations(items_strategies["or"], original_scope)
    exclude_relations = merge_relations(items_strategies["exclude"], original_scope)

    and_relations = and_relations.merge(exclude_relations) if items_strategies["exclude"].present?

    if items_strategies["or"].present?
      return and_relations.or(or_relations) if items_strategies["and"].present?

      return or_relations
    end

    and_relations
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
    criteria.keys.each do |key|
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

    relations = strategies.first
    strategies.drop(1).each do |relation|
      # Needed for reference filter search
      relation = relation.unscope(where: :item_type_id) if relations.to_sql.include?("parent_items")
      relations = relations.or(relation)
    end

    relations
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
end
