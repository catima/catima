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
    return item_display_name(item) if item_view.nil?

    presenter = ItemViewPresenter.new(self, item_view, item, I18n.locale, options)
    presenter.render
  end

  def item_summary(item)
    at_least_editor = current_user.catalog_role_at_least?(item.catalog, 'editor')

    # Retrieve all applicable fields for the summary & join the values
    item.applicable_list_view_fields.each_with_object([]) do |fld, html|
      # Remove restricted fields unless the user is at least an editor
      next unless at_least_editor || !fld.restricted?

      # Remove field if primary
      next if fld == item.primary_field

      # Remove non human readable fields unless field is filterable
      next unless fld.human_readable? || fld.filterable?

      # Remove all html tags
      value = strip_tags(field_value(item, fld, :style => :compact))

      # Remove field if value is blank
      next if value.blank?

      html << [content_tag(:b, "#{fld.name}:"), value].join(" ")
    end.join("; ").html_safe
  end

  def item_display_name(item)
    item_view = item.item_type.default_display_name_view
    return default_display_name(item) if item_view.nil?

    presenter = ItemViewPresenter.new(self, item_view, item, I18n.locale, strip_p: true)
    presenter.render
  end

  def default_display_name(item)
    field = item.field_for_select
    return item.to_s if field.nil?

    strip_tags(field_value(item, field, :style => :compact)) || ''.html_safe
  end

  # Check that the referer is the item type list (Data mode)
  # of the same item type
  def referer_with_same_item_type?(item)
    return false unless request.referer

    referer = Rails.application.routes.recognize_path(URI(request.referer).path)
    return false if referer.key?(:id)

    return false unless referer.key?(:item_type_slug)

    referer[:item_type_slug].eql? item.item_type.slug
  end
end
