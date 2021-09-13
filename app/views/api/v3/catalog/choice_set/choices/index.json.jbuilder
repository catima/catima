json.data do
  json.partial! partial: 'choice', collection: @choices, as: :choice, locals: {no_childrens: false, no_parent: true}
end
