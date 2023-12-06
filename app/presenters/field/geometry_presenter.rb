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
    @view.render(
      'fields/geometries',
      features: features_with_properties,
      layers: field.geo_layers,
      zoom_level: field.zoom_level
    )
  end

  def features_with_properties
    raw_value['features'].each do |feature|
      feature['properties']['polygon_color'] = field.polygon_color
      feature['properties']['polyline_color'] = field.polyline_color
    end || []
  end
end
