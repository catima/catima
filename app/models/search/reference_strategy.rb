class Search::ReferenceStrategy < Search::BaseStrategy
  def browse(scope, item_id)
    return scope.none if item_id.nil?
    scope.where("#{data_field_expr} = ?", item_id)
  end
end
