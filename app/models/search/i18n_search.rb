module Search::I18nSearch
  private

  def data_field_expr
    return super unless field.i18n?

    "items.data->'#{field.uuid}'->'_translations'->>'#{locale}'"
  end
end
