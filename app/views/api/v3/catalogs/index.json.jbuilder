json.data do
  json.partial! 'catalog', collection: @catalogs, as: :catalog
end
