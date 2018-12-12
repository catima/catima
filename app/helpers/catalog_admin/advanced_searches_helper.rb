module CatalogAdmin::AdvancedSearchesHelper
  def setup_catalog_advanced_searches_nav_link
    active = (params[:controller] == "catalog_admin/advanced_search_configurations")
    klass = "list-group-item"
    klass << " active" if active

    link_to(t("advanced_searches.menu"), catalog_admin_advanced_search_configurations_path, :class => klass)
  end

  def advanced_search_field_move_up_link(field)
    advanced_search_field_move_link(field, "up")
  end

  def advanced_search_field_move_down_link(field)
    advanced_search_field_move_link(field, "down")
  end

  private

  def advanced_search_field_move_link(field, direction)
    link_to(
      fa_icon(:"caret-#{direction}"),
      {
        :action => "update",
        :advanced_search_configuration => {
          :field => field,
          :field_position => direction
        }
      },
      :method => :patch,
      :remote => true
    )
  end
end
