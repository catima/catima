class Field::DateTimePresenter < FieldPresenter
  delegate :l, :content_tag, :json_react_component, :to => :view

  def value
    # TODO: move this logic down to Field::DateTime?
    return nil if raw_value.nil?
    v = raw_value
    dt = DateTime.civil_from_format(:local, (v['Y'] || 0), (v['M'] || 1), (v['D'] || 1), (v['h'] || 0), (v['m'] || 0), (v['s'] || 0))
    dt && l(dt, format: field.format.to_sym)
  end

  def input(form, method, _options={})
    form.form_group(method, :label => { :text => label }) do
      json_react_component("DateTimeInput", form, field)
    end
  end
end
