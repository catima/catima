class ContainerPresenter
  attr_reader :view, :container, :options

  def initialize(view, container, options={})
    @view = view
    @container = container
    @options = options
  end

  def html
    @view.render('containers/'+@container.partial_name, {
      container:@container, presenter:self
    })
  end
end
