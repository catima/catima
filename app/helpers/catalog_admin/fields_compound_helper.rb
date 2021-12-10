module CatalogAdmin::FieldsCompoundHelper
  def compoundable?(field)
    field.human_readable? && !field.is_a?(Field::Compound)
  end
end
