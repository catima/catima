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

  def item_summary(item)
    item.applicable_list_view_fields.each_with_object([]) do |field, html|
      next if field == item.primary_field
      value = strip_tags(field_value(item, field, :style => :compact))
      next if value.blank?
      html << [content_tag(:b, "#{field.name}:"), value].join(" ")
    end.join("; ").html_safe
  end

  def item_display_name(item)
    field = item.field_for_select
    return item.to_s if field.nil?

    strip_tags(field_value(item, field, :style => :compact))
  end
end
