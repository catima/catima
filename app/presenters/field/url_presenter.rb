class Field::URLPresenter < FieldPresenter
  delegate :link_to, :to => :view

  def input(form, method, options={})
    form.url_field(method, input_defaults(options).reverse_merge(:help => help))
  end

  def value
    return if raw_value.blank?
    compact = raw_value[%r{^https?://(.+?)/?$}, 1] || raw_value
    link_to(compact, raw_value, :target => "_blank")
  end
end
