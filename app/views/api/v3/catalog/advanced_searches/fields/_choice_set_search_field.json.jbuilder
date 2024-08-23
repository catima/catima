json.set! 0 do
  json.field_condition %w(and or exclude)
  json.value ':choice_id'
  json.child_choices_activated 'true false'
end
