class FieldPresenter
  attr_reader :view, :item, :field

  def initialize(view, item, field)
    @view = view
    @item = item
    @field = field
  end

  def raw_value
    item.behaving_as_type.send(field.uuid)
  end
  alias_method :value, :raw_value
end
