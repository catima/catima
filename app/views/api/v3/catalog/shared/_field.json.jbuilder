json.id field.id
json.uuid field.uuid
json.slug field.slug
json.type field.type
json.created_at field.created_at
json.updated_at field.updated_at
json.name field.name_translations

json.name_plural field.name_plural_translations

json.comment field.comment
json.default_value field.default_value

json.primary field.primary
json.display_in_list field.display_in_list
json.display_in_public_list field.display_in_public_list
json.restricted field.restricted
json.style field.style
json.unique field.unique

json.field_specific_keys do
  if field.is_a?(Field::ChoiceSet)
    json.choice_set_id field.choice_set_id
  end

  if field.is_a?(Field::DateTime)
    json.format field.format
  end

  if field.is_a?(Field::Decimal)
    json.maximum field.maximum
    json.minimum field.minimum
  end

  if field.is_a?(Field::Editor)
    json.updater field.updater
    json.timestamps field.timestamps
  end

  if field.is_a?(Field::File)
    json.types field.types
  end

  if field.is_a?(Field::Geometry)
    json.bounds field.bounds
    json.layers field.layers
  end

  if field.is_a?(Field::Image)
    json.legend field.legend
  end

  if field.is_a?(Field::Int)
    json.maximum field.maximum
    json.minimum field.minimum
    json.auto_increment field.auto_increment
  end

  if field.is_a?(Field::Reference)
    json.related_item_type_id field.related_item_type_id
  end

  if field.is_a?(Field::Text)
    json.maximum field.maximum
    json.minimum field.minimum
    json.formatted_text field.formatted_text
  end

  if field.is_a?(Field::Xref)
    json.xref field.xref
  end
end

json.field_set_type field.field_set_type
json.multiple field.multiple
json.required field.required
json.row_order field.row_order

# json.category_item_type_id field.category_item_type_id
# json.display_component field.display_component
# json.editor_component field.editor_component
# json.field_set_id field.field_set_id
# json.i18n field.i18n
# json.options field.options
# json.ordered field.ordered
# json.related_item_type_id field.related_item_type_id

