json.data do
  json.partial! partial: 'item', collection: @items, as: :item, locals: { with_field_values: false, with_summary:true }
end
