json.set! 0 do
  json.field_condition %w(and or exclude)
  json.condition %w(one_word all_word)
  json.default ':reference_id'
  json.value ':query'
end
