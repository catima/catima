# == Schema Information
#
# Table name: items
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  creator_id     :integer
#  data           :json
#  id             :integer          not null, primary key
#  item_type_id   :integer
#  review_status  :string           default("not-ready"), not null
#  reviewer_id    :integer
#  search_data_de :text
#  search_data_en :text
#  search_data_fr :text
#  search_data_it :text
#  updated_at     :datetime         not null
#

module ItemsHelper
  def browse_similar_items_link(label, item, field, value)
    link_to(
      label,
      items_path(
        :catalog_slug => item.catalog,
        :item_type_slug => item.item_type,
        :locale => I18n.locale,
        field.slug => value
      ))
  end

  def item_has_thumbnail?(item)
    item.image?
  end

  def item_thumbnail(item, options={})
    field = item.list_view_fields.find { |f| f.is_a?(Field::Image) }
    return if field.nil?
    field_value(item, field, options.reverse_merge(:style => :compact))
  end

  def item_list_view(item, options={})
    item_view = item.item_type.default_list_view
    return item_display_name if item_view.nil?
    presenter = ItemViewPresenter.new(self, item_view, item, I18n.locale, options)
    presenter.render
  end

  def item_summary(item)
    item.applicable_list_view_fields.each_with_object([]) do |field, html|
      next if field == item.primary_field
      next unless field.human_readable?
      value = strip_tags(field_value(item, field, :style => :compact))
      next if value.blank?
      html << [content_tag(:b, "#{field.name}:"), value].join(" ")
    end.join("; ").html_safe
  end

  def item_display_name(item)
    field = item.field_for_select
    return item.to_s if field.nil?

    strip_tags(field_value(item, field, :style => :compact)).html_safe
  end
end
