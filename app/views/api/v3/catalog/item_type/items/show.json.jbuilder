json.data do
  json.partial! partial: 'item', locals: { item: @item, fields: @fields, with_field_values: true, with_summary: false }
end
