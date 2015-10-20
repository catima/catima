class Field::IntPresenter < FieldPresenter
  delegate :number_with_delimiter, :to => :view

  def value
    number_with_delimiter(raw_value)
  end
end
