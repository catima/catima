include ActionView::Helpers::OutputSafetyHelper

class Field::TextPresenter < FieldPresenter
  delegate :locale_form_group, :truncate, :to => :view

  def value
    v = compact? ? truncate(super.to_s, :length => 100) : super
    field.formatted_text ? render_markdown(v) : v
  end

  def input(form, method, options={})
    i18n = options.fetch(:i18n) { field.i18n? }
    return i18n_input(form, method, options) if i18n
    form.text_area(method, input_defaults(options).merge(:rows => 1))
  end

  def i18n_input(form, method, options={})
    locale_form_group(form, method, :text_field, input_defaults(options))
  end

  def render_markdown(t)
    v = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: true, tables: true
    ).render(t)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    safe_join([white_list_sanitizer.sanitize(v).html_safe])
  end
end
