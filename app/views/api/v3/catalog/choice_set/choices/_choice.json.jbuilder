json.id choice.id
json.position choice.position
if choice.category
  json.category do
    json.partial! '/api/v3/catalog/categories/category', category: choice.category
  end
end
json.long_name_translations choice.long_name_translations
json.short_name_translations choice.short_name_translations
if choice.choice_set.choice_set_type === 'datation'
  json.from JSON(choice.from_date)
  json.to JSON(choice.to_date)
end
if choice.childrens.any? && !no_childrens
  json.childrens do
    json.partial! partial: 'choice', collection: choice.childrens, as: :choice, locals: {no_childrens: false, no_parent: true}
  end
end
unless no_parent
  if choice.parent.present?
    json.parent do
      json.partial! partial: 'choice', locals: {choice: choice.parent, no_childrens: true, no_parent: false}
    end
  end
end
