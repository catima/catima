json.field_condition %w(and or exclude)
json.condition %w(exact less_than less_than_or_equal_to greater_than greater_than_or_equal_to)
json.exact ':decimal if condition == exact'
json.less_than ':decimal if condition == less_than'
json.less_than_or_equal_to ':decimal if condition == less_than_or_equal_to'
json.greater_than ':decimal if condition == greater_than'
json.greater_than_or_equal_to ':decimal if condition == greater_than_or_equal_to'
