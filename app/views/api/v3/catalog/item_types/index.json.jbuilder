json.data do
  json.partial! 'item_type', collection: @item_types, as: :item_type
end
