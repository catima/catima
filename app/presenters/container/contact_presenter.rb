class Container::ContactPresenter < ContainerPresenter
  def html
    inputs = container.content.except('receiving_email').sort_by { |_key, value| JSON.parse(value)["row_order"] }
    inputs = inputs.select { |_key, value| JSON.parse(value)["enabled"] }

    @view.render("containers/contact", :container => container, :inputs => inputs)
  end
end
