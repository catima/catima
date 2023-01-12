json.id choice_set.id
json.name choice_set.name
json.type choice_set.choice_set_type
if choice_set.choice_set_type === 'datation'
  json.format choice_set.format
  json.allow_bc choice_set.allow_bc
end
json.created_at choice_set.created_at
json.is_active choice_set.not_deactivated?
