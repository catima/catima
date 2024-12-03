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

  def robots
    begin
      restricted_bots = YAML.load_file('config/restricted_robots.yml') || []
    rescue StandardError
      restricted_bots = []
    end

    indexed_catalogs = Catalog
                       .not_deactivated
                       .where(:seo_indexable => true)
                       .pluck(:slug)
    robots_txt = ""
    if restricted_bots.any?
      restricted_bots_list = restricted_bots.map { |bot| "User-agent: #{bot}" }.join("\n")
      robots_txt << restricted_bots_list << "\nDisallow: /\n\n"
    end

    robots_txt += <<~ROBOTS
      User-agent: *
      Crawl-Delay: 5
      #{indexed_catalogs.map { |slug| "Allow: /#{slug}/" }.join("\n")}
      Disallow: /
    ROBOTS

    render plain: robots_txt
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
