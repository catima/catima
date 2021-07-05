json.id item_type.id
json.slug item_type.slug
json.set! "name_#{item_type.catalog.primary_language}", item_type.public_send("name_#{item_type.catalog.primary_language}")
if item_type.catalog.other_languages
  item_type.catalog.other_languages do | lang |
    json.set! "name_#{lang}", item_type.public_send("name_#{lang}")
  end
end
json.display_emtpy_fields item_type.display_emtpy_fields
