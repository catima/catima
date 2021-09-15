class HomeController < ApplicationController
  prepend_view_path TemplateStorage.resolver

  def index
    @config = ::Configuration.first!
    @catalogs = Catalog.not_deactivated.sorted

    if (catalog = @config.active_redirect_catalog)
      redirect_to_catalog(catalog)
    elsif @config.root_mode == "custom"
      render_custom_root
    else
      render("listing")
    end
  end

  private

  def redirect_to_catalog(catalog)
    redirect_to(catalog_home_path(catalog, :locale => catalog.primary_language))
  end

  def render_custom_root
    custom_view = Rails.root.join("catalogs/root.html.erb")
    return render(:file => custom_view) if custom_view.file?

    render("index")
  end
end
