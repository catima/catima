# Code that is common between fields that can be multivalued, such as
# Reference and ChoiceSet.
module Search::MultivaluedSearch
  private

  def search_data_matching_one_or_more(scope, exact_values)
    exact_values = Array.wrap(exact_values).select(&:present?)
    return scope if exact_values.empty?

    if field.multiple?
      scope.where("#{data_field_jsonb_expr} ?| array[:v]", :v => exact_values)
    else
      scope.where("#{data_field_expr} IN (?)", exact_values)
    end
  end

  def data_field_jsonb_expr
    "(items.data->'#{field.uuid}')::jsonb"
  end
end
