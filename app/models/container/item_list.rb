class Container::ItemList < ::Container
  store_accessor :content, :itemtype

  def custom_container_permitted_attributes
    %i(itemtype)
  end

  def render
    content['itemtype']
  end
end