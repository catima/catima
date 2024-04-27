module CatalogAdmin::MapHelper
  # Load the geo layers data from a yml file
  def load_geo_layers
    YAML.load_file('config/geo_layers.yml') || []
  rescue StandardError => e
    Rails.logger.error "[ERROR] Geo layers: #{e.message}"
    []
  end

  def popup_display_name(item)
    return item_display_name(item).truncate(80) if item_display_name(item).present?

    t('containers.map.view_item')
  end
end
