class Field::ComplexDatationPresenter < FieldPresenter
  include ItemsHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers

  delegate :l, :to => :view

  def value(format: false)
    dt = raw_value
    return nil if dt.nil? || dt.values.all?(&:blank?)

    case dt['selected_format']
    when 'date_time'

      if dt['to'] == dt['from']
        style = 'exact'
      elsif dt['to'].values.all?(&:blank?)
        style = "from"
      elsif dt['from'].values.all?(&:blank?)
        style = 'to'
      else
        style = 'between'
      end

      from = value_text_repr(dt['from'], format, date_name: 'from')
      to = value_text_repr(dt['to'], format, date_name: 'to')

      from = dt['from']['BC'] ? I18n.t('catalog_admin.fields.complex_datation.bc', date: from) : from
      to = dt['to']['BC'] ? I18n.t('catalog_admin.fields.complex_datation.bc', date: to) : to

      case style
      when 'exact'
        from
      when 'from'
        I18n.t('catalog_admin.fields.complex_datation.after', date: from)
      when 'to'
        I18n.t('catalog_admin.fields.complex_datation.before', date: to)
      when 'between'
        I18n.t('catalog_admin.fields.complex_datation.between', from: from, to: to)
      end
    when 'datation_choice'
      choices_value(dt)
    else
    end
  end

  def choices_value(raw_val)
    choices = field.selected_choices(item)
    return if choices.empty?

    links_and_prefixed_names = choices.map do |choice|
      value_slug = [I18n.locale, choice.short_name].join("-")
      html_options = {'data-toggle': "tooltip", title: choice_dates(choice.from_date, choice.to_date, choice.choice_set.format, raw_val['selected_choices']['BC'])}
      [
        browse_similar_items_link(
          choice.long_display_name, item, field, value_slug, html_options: html_options
        ),
        browse_similar_items_link(
          choice.choice_set.choice_prefixed_label(choice, format: :long), item, field, value_slug, html_options: html_options
        ),
        choice.choice_set.choice_prefixed_label(choice, format: :long),
      ]
    end
    if links_and_prefixed_names.size >= 1 && options[:style] != :compact
      tag.div(
        links_and_prefixed_names.map do |_link, prefixed_link|
          tag.div(tag.div(prefixed_link))
        end.join(" ").html_safe
      )
    else
      links_and_prefixed_names.map(&:first).join(", ").html_safe
    end
  end

  def choice_dates(from, to, format, bc)
    from = value_text_repr(from, format)
    to = value_text_repr(to, format)
    from = bc ? I18n.t('catalog_admin.fields.complex_datation.bc', date: from) : from
    to = bc ? I18n.t('catalog_admin.fields.complex_datation.bc', date: to) : to
    I18n.t('catalog_admin.fields.complex_datation.between', from: from, to: to)
  end

  def value_text_repr(dt, format, date_name: false)
    format_str = (format || field.format).chars.reject { |v| dt[v].blank? }.join
    validate_datetime_format_string(format_str)
    return nil if format_str.empty?

    begin
      dt_value = DateTime.civil_from_format(:local, *prepare_datetime_array(date_name: date_name, value: date_name ? false : dt))
      text_repr = I18n.l(dt_value, format: format_str.to_sym)
      text_repr.sub('8888', dt[0].to_s) if dt["raw_value"].nil?
    rescue StandardError
      nil
    end
  end

  def input(form, method, options = {})
    form.text_field(method, input_defaults(options))
  end

  private

  def prepare_datetime_array(date_name: false, value: false)
    dt = value ? field.value_as_array(item, date_name: date_name, value: value) : field.value_as_array(item, date_name: date_name)
    dt.enum_for(:each_with_index).map do |v, i|
      if v.present?
        v
      else
        i == 0 ? 8888 : 1
      end
    end
  end

  def validate_datetime_format_string(dtstr)
    s = dtstr
    loop do
      break if Field::DateTime::FORMATS.include?(s) || s.empty?

      s = s[0...-1]
    end
    s
  end
end
