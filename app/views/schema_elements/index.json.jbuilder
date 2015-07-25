json.array!(@schema_elements) do |schema_element|
  json.extract! schema_element, :id, :name, :description, :instance_id
  json.url schema_element_url(schema_element, format: :json)
end
