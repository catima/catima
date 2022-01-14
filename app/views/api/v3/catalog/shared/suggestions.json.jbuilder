json.data do
  json.array! @suggestions do |suggestion|
    json.id suggestion.id
    json.catalog_id suggestion.catalog_id
    json.item_type_id suggestion.item_type_id
    json.item_id suggestion.item_id
    json.user_id suggestion.user_id
    json.processed_at suggestion.processed_at? ? I18n.l(suggestion.processed_at) : nil
    json.content suggestion.content
  end
end
