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
    local_tpl = tpl[@locale.to_s] || ''
    # Filter away http and https before item link
    local_tpl = local_tpl.sub('http://{{_itemLink}}', '{{_itemLink}}')
    local_tpl = local_tpl.sub('https://{{_itemLink}}', '{{_itemLink}}')
    local_tpl = local_tpl.sub('{{_itemLink}}', item_link)
    @item.fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, {})
      local_tpl = local_tpl.sub('{{' + field.slug + '}}', presenter.value || '')
    end
    (@options[:strip_p] == true ? strip_p(local_tpl) : local_tpl).html_safe
  end

  def strip_p(html)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    white_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub))
  end
end
