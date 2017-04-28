class Field::DateTimePresenter < FieldPresenter
  delegate :l, :react_component, :to => :view

  def value
    return nil if raw_value.nil?
    v = raw_value
    dt = DateTime.civil_from_format(:local, (v['Y'] || 0), (v['M'] || 1), (v['D'] || 1), (v['h'] || 0), (v['m'] || 0), (v['s'] || 0))
    dt && l(dt, format: field.format.to_sym)
  end

  def input(form, method, options={})
    html = [
      form.text_area(
        "#{method}_json",
        input_defaults(options).reverse_merge(
          :rows => 1,
          :format => field.format,
          'data-field-type' => 'datetime'
        )
      ),
      '<div class="date-time-input-wrapper">',
      react_component('DateTimeInput', {
        field: method, granularity: field.format, date: raw_value
      }),
      '</div>'
    ]
    html.compact.join.html_safe
  end
end
