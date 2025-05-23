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

  def catalog_keyword_badges(catalog)
    return unless catalog.comments

    # Find all keywords in the string (#my_keyword), and add a badge for each one
    badges = catalog.comments.scan(/#(\w+)/).flatten.map do |badge|
      tag.span(badge, class: "badge rounded-pill text-bg-secondary me-1")
    end

    # Return the badges as a safe HTML string
    safe_join(badges)
  end
end
