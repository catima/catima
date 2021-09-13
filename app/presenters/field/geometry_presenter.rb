class Field::GeometryPresenter < FieldPresenter
  delegate :tag, :to => :view

  def input(form, method, options={})
    form.text_area(
      "#{method}_json",
      input_defaults(options).reverse_merge(:rows => 1)
    )
  end

  def value
    return nil unless value?

    geo_viewer
  end

  def value?
    return false if raw_value.blank? || raw_value['features'].blank?

    true
  end

  private

  def input_data_defaults(data)
    super.reverse_merge("geo-input" => true)
  end

  def geo_viewer
    @view.render('fields/geometries', features: raw_value['features'], layers: field.geo_layers)
  end
end
