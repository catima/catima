class HomeController < ApplicationController
  def index
    @config = ::Configuration.first!
    @catalogs = Catalog.active.sorted

    case @config.root_mode
    when "listing"
      render("listing")
    when "redirect"
      redirect_to_catalog(@config.default_catalog)
    else
      render_custom_root
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
