class Container::HTML < ::Container
  store_accessor :content, :html

  def custom_container_permitted_attributes
    %i(html)
  end

  def render_view(options={})
    content['html']
  end
end
