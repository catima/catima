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
    # TODO: Improve where these are retrieved / informed.
    commercial_bots = [
      "psbot", "PetalBot", "Mail.RU_Bot", "MegaIndex", "Baiduspider",
      "360Spider", "Yisouspider", "Bytespider", "Sogou web spider",
      "Sogou inst spider", "proximic", "ADmantX", "Seekport Crawler", "BLEXBot",
      "MJ12bot", "dotbot", "GPTBot", "ChatGPT-User", "CCBot"
    ]

    indexed_catalos = Catalog
                      .not_deactivated
                      .where(:seo_indexable => true)
                      .pluck(:slug)

    robots_txt = <<~ROBOTS
      #{commercial_bots.map { |bot| "User-agent: #{bot}" }.join("\n")}
      Disallow: /

      User-agent: *
      Crawl-Delay: 5
      #{indexed_catalos.map { |slug| "Allow: /#{slug}/" }.join("\n")}
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
