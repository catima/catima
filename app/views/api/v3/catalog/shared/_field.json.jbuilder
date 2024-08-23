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
  if field.is_a?(Field::Embed)
    json.format field.iframe? ? 'iframe' : 'url'
    json.domains field.parsed_domains
    if field.url?
      json.width field.width
      json.height field.height
    end
  end

  if field.is_a?(Field::ComplexDatation)
    json.format field.format
    json.allow_date_time_bc field.allow_date_time_bc
    json.allowed_formats field.allowed_formats.reject(&:blank?)
    json.choice_set_ids field.choice_set_ids.reject(&:blank?)
  end

  json.choice_set_id field.choice_set_id if field.is_a?(Field::ChoiceSet)

  json.format field.format if field.is_a?(Field::DateTime)

  json.template field.template if field.is_a?(Field::Compound)

  if field.is_a?(Field::Decimal)
    json.maximum field.maximum
    json.minimum field.minimum
  end

  if field.is_a?(Field::Editor)
    json.updater field.updater
    json.timestamps field.timestamps
  end

  json.types field.types if field.is_a?(Field::File)

  if field.is_a?(Field::Geometry)
    json.bounds field.bounds
    json.layers field.layers
  end

  json.legend field.legend if field.is_a?(Field::Image)

  if field.is_a?(Field::Int)
    json.maximum field.maximum
    json.minimum field.minimum
    json.auto_increment field.auto_increment
  end

  json.related_item_type_id field.related_item_type_id if field.is_a?(Field::Reference)

  if field.is_a?(Field::Text)
    json.maximum field.maximum
    json.minimum field.minimum
    json.formatted_text field.formatted_text
  end

  json.xref field.xref if field.is_a?(Field::Xref)
end

json.field_set_type field.field_set_type
json.multiple field.multiple
json.required field.required
json.row_order field.row_order
