module ItemsHelper
  # TODO: refactor search-related helpers in presenters

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

  def search_item_link(search, item, offset, label=nil, &block)
    context = item_context_params(search)
    context[:offset] = search.offset + offset if context.present?

    link_to(
      block ? capture(&block) : label,
      item_path(context.merge(:item_type_slug => item.item_type, :id => item))
    )
  end

  def render_items_search_nav(search, item)
    nav = search_navigation(search, item)
    return if nav.nil?

    render(
      :partial => "items/search_nav",
      :locals => {
        :nav => nav,
        :search => search,
        :search_path => search_path(search, item, nav)
      }
    )
  end

  def item_context_params(search)
    context = case search
              when Search::Simple
                { :q => search.to_param }
              when Search::Advanced
                { :search => search.to_param }
              when Search::References
                {}
              when Search::Browse
                { :browse => search.to_param }
              end
    context.delete_if { |_, v| v.blank? }
  end

  def search_path(search, item, nav)
    case search
    when Search::Simple
      simple_search_path(
        :q => search.query,
        :page => search.page_for_offset(nav.offset_actual),
        :type => item.item_type.slug
      )
    when Search::Advanced
      advanced_search_path(
        :uuid => search.model.uuid,
        :page => search.page_for_offset(nav.offset_actual)
      )
    when Search::Browse
      items_path(search.field.slug => search.value) if search.field
    end
  end

  def item_has_thumbnail?(item)
    !!item_thumbnail(item)
  end

  def item_thumbnail(item, options={})
    field = item.list_view_fields.find { |f| f.is_a?(Field::Image) }
    return if field.nil?
    field_value(item, field, options.merge(:style => :compact))
  end

  def item_summary(item)
    item.list_view_fields.each_with_object([]) do |field, html|
      next if field == item.primary_field
      value = strip_tags(field_value(item, field, :style => :compact))
      next if value.blank?
      html << [content_tag(:b, "#{field.name}:"), value].join(" ")
    end.join("; ").html_safe
  end

  private

  def search_navigation(search, item)
    return nil if params[:offset].blank?

    Search::Navigation.new(
      :results => search.items.where(:item_type_id => item.item_type_id),
      :offset => params[:offset].to_i,
      :current => item
    )
  end
end
