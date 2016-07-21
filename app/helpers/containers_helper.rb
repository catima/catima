module ContainersHelper
  def container_html(container, options={})
    container_presenter(container, options).html
  end

  def container_presenter(container, options={})
    "Container::#{container.type_name}Presenter".constantize.new(self, container, options)
  end
end
