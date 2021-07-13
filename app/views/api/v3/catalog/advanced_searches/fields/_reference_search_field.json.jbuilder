json.set! 0 do
  json.field_condition %w(and or exclude)
  json.condition %w(one_word all_word)
  json.default ':reference_id'
  json.filter_field_uuid ':field_uuid'
  json.one_word ':query if condition == one_word'
  json.all_words ':query if condition == all_words'
end
