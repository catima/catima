include ActionView::Helpers::OutputSafetyHelper

class Field::TextPresenter < FieldPresenter
  delegate :locale_form_group, :truncate, :react_component, :strip_tags, :to => :view

  def value
    v = begin
      JSON.parse(super || '') || { 'format': 'raw', 'content': '' }
    rescue JSON::ParserError
      {
        'format' => field.formatted_text.to_i == 1 ? 'markdown' : 'raw',
        'content' => super
      }
    end
    c = v['format'] == 'markdown' ? render_markdown(v['content']) : v['content']
    c ||= ''
    compact? ? compact_value(c) : sanitize(c)
  end

  def compact_value(v)
    truncate(strip_tags(v), length: 100).html_safe
  end

  def input(form, method, options={})
    i18n = options.fetch(:i18n) { field.i18n? }
    inp = raw_input(form, method, options, i18n)
    return inp unless field.formatted?
    [
      '<div class="hidden-children-inputs">',
      inp,
      '</div>',
      '<div class="formatted-text-input">',
      i18n ? '<table class="formatted-text-table">' : '',
      formatted_text_input(form, method, options, i18n),
      i18n ? '</table>' : '',
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

  def formatted_text_input(_form, method, _options={}, i18n=false)
    if i18n
      field.catalog.valid_locales.map do |l|
        "<tr><td>#{l}</td><td>" + \
          formatted_text_component("item_#{method}_#{l}") + \
          "</td></tr>"
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
    safe_join([@white_list_sanitizer.sanitize(v).html_safe])
  end
end
