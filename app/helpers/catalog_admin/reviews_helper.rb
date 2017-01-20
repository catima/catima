module CatalogAdmin::ReviewsHelper
  STATUSES = {
    "not-ready" => ["draft", "default"],
    "ready" => ["review", "info"],
    "approved" => ["approved", "success"],
    "rejected" => ["rejected", "warning"]
  }.freeze

  def review_status_label(item)
    text, klass = STATUSES[item.review_status]
    content_tag(:span, t(text), :class => "label label-#{klass}")
  end

  def render_items_approval(item)
    return unless item.review.pending?
    return unless policy(item.review).approve?
    render("catalog_admin/items/approval", :item_type => item.item_type)
  end

  def render_items_review(item, form=nil)
    return unless catalog.requires_review?

    render(
      "catalog_admin/items/review",
      :f => form,
      :review => item.review,
      :item => item,
      :item_type => item.item_type
    )
  end
end
