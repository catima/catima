class Search::ReferenceStrategy < Search::BaseStrategy
  def browse(scope, item_id)
    return scope.none if item_id.nil?

    # TODO: DRY up with ChoiceSetStrategy
    if field.multiple?
      scope.where("#{data_field_jsonb_expr} ?| array[:ids]", :ids => [item_id])
    else
      scope.where("#{data_field_expr} = ?", item_id)
    end
  end

  private

  # TODO: DRY up with ChoiceSetStrategy
  def data_field_jsonb_expr
    "(items.data->'#{field.uuid}')::jsonb"
  end
end
