json.set! 0 do
  json.field_condition %w(and or exclude)
  json.default ':choice_id'
  json.child_choices_activated %{true false}
end

# {"_654455d0_c790_45ac_b3dd_3d6c59cf0a13": {
#   "0": {"field_condition": "and", "default": "939", "child_choices_activated": "true"},
#   "1": {"all_words": "3978", "field_condition": "and", "category_field": "_80ad4733_2f2b_416a_9b3e_5c4a1b12540b", "condition": "all_words", "category_criteria": {"all_words": "Oui"}}
# }
