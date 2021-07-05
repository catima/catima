json.field_condition %w(and or exclude)
json.condition %w(all_words one_word exact)
json.one_word ':query if condition == one_word'
json.all_words ':query if condition == all_words'
json.exact ':query if condition == exact'
