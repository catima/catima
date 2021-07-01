json.data do
  json.partial! '/api/v3/catalog/shared/field', collection: @fields, as: :field
end
