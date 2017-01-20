class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  def value
    return nil if raw_value.nil?
    if raw_value && raw_value['raw_value']
      # Convert old timestamp style values to new JSON representation
      dt = Time.zone.at(raw_value['raw_value'])
    else
      v = raw_value
      dt = DateTime.civil_from_format :local, v['Y'], v['M'] || 0, v['D'] || 0, v['h'] || 0, v['m'] || 0, v['s'] || 0
    end
    dt && l(dt, format: field.format.to_sym)
  end

  def input(form, method, options={})
    form.text_area(
      "#{method}_json",
      input_defaults(options).reverse_merge(
        :rows => 1, 
        :format => field.format, 'data-format' => field.format, 
        'data-field-type' => 'datetime'
      )
    )
  end

end
