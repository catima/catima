module CatalogAdmin::MapHelper
  # Load the geo layers data from a yml file
  def load_geo_layers
    YAML.load_file('config/geo_layers.yml')
  rescue StandardError
    []
  end
end
