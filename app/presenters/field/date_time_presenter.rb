class Field::DateTimePresenter < FieldPresenter
  delegate :l, :content_tag, :json_react_component, :to => :view

  def value
    dt = field.value_as_datetime(item)
    dt && l(dt, format: field.format.to_sym)
  end

  def input(form, method, _options={})
    form.form_group(method, :label => { :text => label }) do
      json_react_component("DateTimeInput", form, field)
    end
  end
end
