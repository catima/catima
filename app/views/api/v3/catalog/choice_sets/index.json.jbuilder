json.data do
  json.partial! 'choice_set', collection: @choice_sets, as: :choice_set
end
