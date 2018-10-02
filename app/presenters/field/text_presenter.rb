include ActionView::Helpers::OutputSafetyHelper

class Field::TextPresenter < FieldPresenter
  delegate :locale_form_group, :truncate, :strip_tags, :to => :view

  def value
    return super if field.formatted_text.to_i == 0

    c = formatted_value(super) || ''
    compact? ? compact_value(c) : sanitize(c)
  end

  def formatted_value(value)
    v = begin
          JSON.parse(value || '') || { 'format': 'raw', 'content': '' }
        rescue JSON::ParserError
          {
            'format' => field.formatted_text.to_i == 1 ? 'markdown' : 'raw',
            'content' => value
          }
        end
    [
      '<div class="formatted-text">',
      v['format'] == 'markdown' ? render_markdown(v['content']) : v['content'],
      '</div>'
    ].compact.join.html_safe
  end

  def compact_value(v)
    truncate(strip_tags(v), length: 100).html_safe
  end

  def input(form, method, options={})
    i18n = options.fetch(:i18n) { field.i18n? }
    inp = raw_input(form, method, options, i18n)
    return inp unless field.formatted?

    [
      '<div class="form-component">',
      '<div class="hidden-children-inputs">',
      inp,
      '</div>',
      '<div class="formatted-text-input">',
      i18n ? '<table class="formatted-text-table">' : '',
      formatted_text_input(form, method, options, i18n),
      i18n ? '</table>' : '',
      '</div>',
      '</div>'
    ].compact.join.html_safe
  end

  def raw_input(form, method, options={}, i18n=false)
    return i18n_input(form, method, options) if i18n

    form.text_area(method, input_defaults(options).merge(:rows => 1))
  end

  def i18n_input(form, method, options={})
    locale_form_group(form, method, :text_field, input_defaults(options))
  end

  def formatted_text_input(form, method, _options={}, i18n=false)
    if i18n
      field.catalog.valid_locales.map do |l|
        errors = form.object.errors.messages["#{method}_#{l}".to_sym]
        "<tr " + (errors.empty? ? '' : 'class="has-error"') + "><td>#{l}</td><td>" + \
          formatted_text_component("item_#{method}_#{l}") + \
          "</td></tr>" + \
          (errors.empty? ? '' : "<tr class=\"has-error msg\"><td colspan=\"2\">#{errors.compact.join(' / ')}</td></tr>")
      end.compact.join
    else
      formatted_text_component("item_#{method}")
    end
  end

  def formatted_text_component(content_ref)
    react_component(
      'FormattedTextEditor',
      props: { contentRef: content_ref },
      prerender: false
    )
  end

  def render_markdown(t)
    t ||= ''
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: true, tables: true
    ).render(t)
  end

  private

  def sanitize(v)
    @white_list_sanitizer ||= Rails::Html::WhiteListSanitizer.new
    # @white_listed_tags ||= Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS_WITH_LIBXML2
    @white_listed_attrs ||= Loofah::HTML5::WhiteList::ALLOWED_ATTRIBUTES + %w[data-note table_id row_id cell_id]
    @white_listed_tags ||= Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS
    safe_join([@white_list_sanitizer.sanitize(v, tags: @white_listed_tags, attributes: @white_listed_attrs).html_safe])
  end
end
