class ChoicePresenter

  def initialize(view, choice)
    @view = view
    @choice = choice
  end

  def dates
    from_repr = value_text_repr(@choice.from_date, @choice.choice_set.format)
    to_repr = value_text_repr(@choice.to_date, @choice.choice_set.format)
    from_repr = @choice.choice_set.allow_bc && JSON.parse(@choice.from_date)['BC'] ? I18n.t('catalog_admin.fields.complex_datation.bc', date: from_repr) : from_repr
    to_repr = @choice.choice_set.allow_bc && JSON.parse(@choice.to_date)['BC'] ? I18n.t('catalog_admin.fields.complex_datation.bc', date: to_repr) : to_repr

    if @choice.from_date == @choice.to_date || from_repr == to_repr
      from_repr
    elsif JSON.parse(@choice.to_date).values.all?(&:blank?)
      I18n.t('catalog_admin.fields.complex_datation.after', date: from_repr)
    elsif JSON.parse(@choice.from_date).values.all?(&:blank?)
      I18n.t('catalog_admin.fields.complex_datation.before', date: to_repr)
    else
      I18n.t('catalog_admin.fields.complex_datation.between', from: from_repr, to: to_repr)
    end
  end

  def value_text_repr(date, format, date_name: false)
    format_str = (format).chars.reject { |v| date.is_a?(Hash) ? date[v].blank? : JSON.parse(date)[v].blank? }.join
    validate_datetime_format_string(format_str)
    return nil if format_str.empty?
    begin
      dt_value = DateTime.civil_from_format(:local, *prepare_datetime_array(date).compact.reject { |c| c.to_s.empty? })

      text_repr = I18n.l(dt_value, format: format_str.to_sym)
      text_repr.sub('8888', date.is_a?(Hash) ? date[0].to_s : JSON.parse(date)[0].to_s) if date["raw_value"].nil?
      text_repr.split().map { |el| el.sub(/^[0]+/, '') }.join(" ")
    rescue StandardError
      nil
    end
  end

  def prepare_datetime_array(date)
    JSON.parse(date).enum_for(:each_with_index).map do |v, i|
      next if v[0] == "BC"

      if v.present?
        v[1]
      else
        i == 0 ? 8888 : 1
      end
    end
  end

  private

  def validate_datetime_format_string(dtstr)
    s = dtstr
    loop do
      break if Field::DateTime::FORMATS.include?(s) || s.empty?

      s = s[0...-1]
    end
    s
  end
end
