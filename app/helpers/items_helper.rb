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
    field = item.fields.find { |f| f.is_a?(Field::Image) && f.display_in_public_list }
    return if field.nil?

    field_value(item, field, options.reverse_merge(:style => :compact))
  end

  def item_list_view(item, options={})
    item_view = item.item_type.default_list_view
    return item_display_name(item) if item_view.nil?

    presenter = ItemViewPresenter.new(self, item_view, item, I18n.locale, options)
    presenter.render
  end

  def item_summary(item, bypass_displayable: false)
    # Retrieve all applicable fields for the summary & join the values
    item.applicable_list_view_fields.each_with_object([]) do |fld, html|
      # Remove field if restricted
      next unless bypass_displayable || fld.displayable_to_user?(current_user)

      # Remove field if primary
      next if fld == item.primary_field

      # Remove field if non human readable unless is filterable
      next unless fld.human_readable? || fld.filterable?

      # Remove all html tags
      value = strip_tags(field_value(item, fld, :style => :compact))

      # Remove field if value is blank
      next if value.blank?

      html << [tag.b("#{fld.name}:"), value].join(" ")
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
    return item.id.to_s if field.nil?

    strip_tags(field_value(item, field, :style => :compact)) || ''.html_safe
  end

  def formatted_item_for_timeline(item, list:, container:, filter_field:)
    title = if item_has_thumbnail?(item)
              tag.div(item_list_link(list, item, 0) { item_thumbnail(item, :class => "media-object") }, class: "pull-left mr-3")
            else
              tag.h4(item_list_link(list, item, 0, item_display_name(item)), class: "mt-0 mb-1")
            end

    item.attributes.merge(
      title: title,
      summary: item_summary(item),
      primary_field_value: field_value(item, item.primary_field),
      filter_field_value: filter_field.is_a?(Field::DateTime) ? filter_field.value_as_array(item, format: container&.field_format) : field_value(item, filter_field),
      group_title: filter_field.is_a?(Field::DateTime) ? Field::DateTimePresenter.new(nil, item, filter_field).value(format: container&.field_format) : field_value(item, filter_field)
    )
  end

  def group_items_for_timeline(items, container:, filter_field:)
    if filter_field.is_a?(Field::DateTime)
      items.group_by do |item|
        container&.field_format && item[:filter_field_value].is_a?(Array) ? item[:filter_field_value].join : item[:filter_field_value]
      end
    else
      items.group_by { |item| item[:filter_field_value] }
    end
  end

  # Check that the referer is the item type list (Data mode)
  # of the same item type
  def referer_with_same_item_type?(item)
    return false unless request.referer

    referer = Rails.application.routes.recognize_path(URI(request.referer).path, method: :post)
    return false if referer.key?(:id)

    return false unless referer.key?(:item_type_slug)

    referer[:item_type_slug].eql? item.item_type.slug
  rescue StandardError
    false
  end
end
