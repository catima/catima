class Field::GeometryPresenter < FieldPresenter
  delegate :content_tag, :to => :view

  def input(form, method, options={})
    form.text_area(
      "#{method}_json",
      input_defaults(options).reverse_merge(:rows => 1)
    )
  end

  def value
    json = raw_value
    return nil if json.blank? || json['features'].blank?

    geo_viewer
  end

  private

  def input_data_defaults(data)
    super.reverse_merge("geo-input" => true)
  end

  def geo_viewer
    @view.render('fields/geometries', features: raw_value['features'], layers: field.geo_layers)
  end
end
