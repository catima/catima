class ViatimagesAdvancedSearchesController < AdvancedSearchesController
  include AdvancedSearchConfig

  def new
    super

    # Sort the advance search configurations by slug to always have the
    # "image" configuration as the first one.
    @advance_search_confs = @advance_search_confs.to_a.sort_by do |conf|
      conf.slug || ''
    end.reverse
  end

  def show
    super

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end
end
