class Field::GeometryPresenter < FieldPresenter
  delegate :number_with_delimiter, :to => :view

  def input(form, method, options={})
    # TODO
  end

  def value
    # TODO
  end
end
