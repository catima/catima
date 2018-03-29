class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  # Returns the date time value as text for presentation.
  # As we support any date of any range, we format the date first with a fixed year (8888),
  # and replace the year after with the true one.
  def value
    dt = field.value_as_array(item)
    return nil if dt.nil?
    # Reverse year & day to be able to create DateTime format & translation strings -> [Y, M, D, h, m, s] to [D, M, Y, h, m, s]
    dt = reverse_year_day(dt)
    dt_string, dt_format = create_strings(dt)
    return nil if dt_string.empty?
    # Dynamically create the translation string
    I18n.backend.store_translations I18n.locale, :time => { :formats => { dt_string => dt_format } }
    # Reverse year & day to be compatible with DateTime function -> [D, M, Y, h, m, s] to [Y, M, D, h, m, s]
    dt = reverse_year_day(dt)
    arr_repr = (0..(dt.length - 1)).collect { |i| i == 0 ? 8888 : dt[i] }
    text_repr = l(DateTime.civil_from_format(:local, *arr_repr), format: dt_string.to_sym)
    text_repr.sub('8888', dt[0].to_s).strip
  end

  def input(form, method, options={})
    form.text_field(method, input_defaults(options))
  end

  private

  def reverse_year_day(dt_array)
    dt_array.insert(0, dt_array.delete_at(2))
    dt_array.insert(2, dt_array.delete_at(1))
  end

  # Create DateTime format & translation strings
  def create_strings(dt_array, dt_string='', dt_format='')
    [%w(D %d),
     %w(M %B),
     %w(Y %Y),
     %W(h %H#{I18n.t('time.formats.h')}),
     %W(m %M#{I18n.t('time.formats.m')}),
     %W(s %S#{I18n.t('time.formats.s')})].each_with_index do |item, index|
      if dt_array[index]
        dt_string.concat(item.first)
        dt_format.concat(item.last.concat(' '))
      else
        dt_array[index] = 1
      end
    end
    [dt_string, dt_format]
  end
end
