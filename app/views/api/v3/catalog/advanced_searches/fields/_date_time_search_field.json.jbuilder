json.field_condition %w(and or exclude)
json.condition %w(exact after before between outside)
json.start do
  json.value do
    json.D ':day'
    json.M ':month'
    json.Y ':year'
  end
end
json.end do
  json.value do
    json.D ':day'
    json.M ':month'
    json.Y ':year'
  end
end
