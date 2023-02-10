# Code that is common between fields that can be multivalued, such as
# Reference and ChoiceSet.
module Search::MultivaluedSearch
  private

  def search_data_matching_one_or_more(scope, exact_values, negate: false)
    if field.multiple?
      search_data_matching_more(scope, exact_values, negate)
    else
      search_data_matching_one(scope, exact_values, negate)
    end
  end

  def search_data_matching_one(scope, exact_values, negate: false)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    where_scope = ->(*where_query) { negate ? scope.where.not(where_query) : scope.where(where_query) }
    where_scope.call("#{data_field_expr} LIKE ?", exact_values)
  end

  def search_data_matching_more(scope, exact_values, negate: false)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    where_scope = ->(*where_query) { negate ? scope.where.not(where_query) : scope.where(where_query) }
    where_scope.call("#{data_field_jsonb_expr} ?| array[:v]", :v => exact_values)
  end

  def search_data_matching_more_complex_datation_choice(scope, exact_values, negate: false)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    where_scope = ->(*where_query) { negate ? scope.where.not(where_query) : scope.where(where_query) }
    where_scope.call("#{data_complex_datation_field_jsonb_expr} ?| array[:v]", :v => exact_values)
  end

  def search_data_matching_all(scope, exact_values, negate: false)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    where_scope = ->(*where_query) { negate ? scope.where.not(where_query) : scope.where(where_query) }
    if field.multiple?
      where_scope.call("#{data_field_jsonb_expr} ?& array[:v]", :v => exact_values)
    else
      where_scope.call("#{data_field_expr} LIKE ?", exact_values)
    end
  end

  def data_field_jsonb_expr
    "(#{sql_select_name.presence || 'items'}.data->'#{field.uuid}')::jsonb"
  end

  def data_complex_datation_field_jsonb_expr
    "(#{sql_select_name.presence || 'items'}.data->'#{field.uuid}'->'selected_choices'->'value')::jsonb"
  end
end
