json.array!(@instances) do |instance|
  json.extract! instance, :id, :name, :url, :description
  json.url instance_url(instance, format: :json)
end
