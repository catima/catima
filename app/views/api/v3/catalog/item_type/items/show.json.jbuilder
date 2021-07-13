json.data do
  json.partial! partial: 'item', locals: { item: @item, with_field_values: true }
end
