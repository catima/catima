json.data do
  json.partial! partial: 'choice', locals: {choice: @choice, no_childrens: false, no_parent: false}
end
