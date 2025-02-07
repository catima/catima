module Admin::CatalogsHelper
  def catalog_api_badge(catalog)
    return unless catalog.api_enabled

    tag.span(t("api").downcase, :class => "badge text-bg-info")
  end

  def catalog_review_badge(catalog)
    return unless catalog.requires_review

    tag.span(t("review_badge").downcase, :class => "badge text-bg-info")
  end

  def catalog_data_only_badge(catalog)
    return unless catalog.data_only?

    tag.span(t("activerecord.attributes.catalog.data_only").downcase, :class => "badge text-bg-info")
  end

  def catalog_seo_indexable_badge(catalog)
    return unless catalog.seo_indexable

    tag.span(
      t("activerecord.attributes.catalog.seo_indexable").downcase,
      :class => "badge text-bg-info"
    )
  end
end
