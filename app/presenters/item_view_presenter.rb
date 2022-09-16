# rubocop:disable Rails/OutputSafety
class ItemViewPresenter
  def initialize(view, item_view, item, locale, options={})
    @view = view
    @item_view = item_view
    @item = item
    @locale = locale
    @options = options
  end

  def item_link
    "/#{@item.catalog.slug}/#{I18n.locale}/#{@item.item_type.slug}/#{@item.id}"
  end

  def render
    tpl = JSON.parse(@item_view.template)
    local_template = tpl[@locale.to_s] || ''
    # Filter away http and https before item link
    local_template = local_template.sub('http://{{_itemLink}}', '{{_itemLink}}')
    local_template = local_template.sub('https://{{_itemLink}}', '{{_itemLink}}')
    local_template = local_template.sub('{{_itemLink}}', item_link)

    # We want only human readable fields for the display_name type of item_view
    fields = @item_view.default_for_display_name ? @item.fields.select(&:human_readable?) : @item.fields

    fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, {})
      local_template = local_template.sub("{{#{field.slug}}}", presenter.value || '')
    end
    (@options[:strip_p] == true ? strip_p(local_template) : local_template).html_safe
  end

  def strip_p(html)
    allow_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    allow_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub a))
  end
end
