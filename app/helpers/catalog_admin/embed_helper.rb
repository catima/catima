module CatalogAdmin::EmbedHelper
  # Load the domains data from a yml file
  def load_domains
    YAML.load_file('config/domains.yml') || []
  rescue StandardError => e
    Rails.logger.error "[ERROR] Domains: #{e.message}"
    []
  end
end
