json.field_condition %w(and or exclude)
json.condition %w(exact less_than less_than_or_equal_to greater_than greater_than_or_equal_to)
json.exact ':integer if condition == exact'
json.less_than ':integer if condition == less_than'
json.less_than_or_equal_to ':integer if condition == less_than_or_equal_to'
json.greater_than ':integer if condition == greater_than'
json.greater_than_or_equal_to ':integer if condition == greater_than_or_equal_to'
