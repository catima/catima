# Code that is common between fields that can be multivalued, such as
# Reference and ChoiceSet.
module Search::MultivaluedSearch
  private

  def search_data_matching_one_or_more(scope, exact_values, negate=false)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    where_scope = ->(*where_query) { negate ? scope.where.not(where_query) : scope.where(where_query) }
    if field.multiple?
      where_scope.call("#{data_field_jsonb_expr} ?| array[:v]", :v => exact_values)
    else
      where_scope.call("#{data_field_expr} LIKE ?", exact_values)
    end
  end

  def search_data_matching_all(scope, exact_values, negate=false)
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
end
