module AdvancedSearchConfig
  def search_conf_param
    search_conf = AdvancedSearchConfiguration.find_by(slug: 'images') || AdvancedSearchConfiguration.find_by(slug: 'corpus')
    @search_conf_param = search_conf ? "advanced_search_conf=#{search_conf.id}" : nil
  end
end
