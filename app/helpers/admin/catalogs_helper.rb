module Admin::CatalogsHelper
  def catalog_api_badge(catalog)
    return unless catalog.api_enabled

    tag.span(t("api").downcase, :class => "badge badge-info")
  end
end
