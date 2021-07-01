json.id field.id
json.uuid field.uuid
json.slug field.slug
json.type field.type
json.created_at field.created_at
json.updated_at field.updated_at

json.name_fr field.name_fr
json.name_en field.name_en
json.name_de field.name_de
json.name_it field.name_it

json.name_plural_fr field.name_plural_fr
json.name_plural_en field.name_plural_en
json.name_plural_de field.name_plural_de
json.name_plural_it field.name_plural_it

json.comment field.comment
json.default_value field.default_value

json.primary field.primary
json.display_in_list field.display_in_list
json.display_in_public_list field.display_in_public_list
json.restricted field.restricted
json.restricted field.style
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

json.category_item_type_id field.category_item_type_id
json.display_component field.display_component
json.editor_component field.editor_component
json.field_set_id field.field_set_id
json.field_set_type field.field_set_type
json.i18n field.i18n
json.multiple field.multiple
json.name_plural_translations field.name_plural_translations
json.name_translations field.name_translations
json.options field.options
json.ordered field.ordered
json.related_item_type_id field.related_item_type_id
json.required field.required
json.row_order field.row_order

