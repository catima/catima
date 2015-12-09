module AdvancedSearchesHelper
  # Renders the contents of the `_#{field_type}_search_field.html.erb` partial
  # and then yields it to the given block. If the partial doesn't render
  # anything (i.e. it is empty), then we assume that field is not searchable.
  # In this case the block is not rendered.
  #
  # This block rendering technique allows the template to specify wrapper
  # markup (e.g. <tr> ... </tr>). The wrapper will only be rendered if the
  # inner content is present.
  #
  def render_advanced_search_field(form, field, &block)
    model_name = field.partial_name
    partial = "advanced_searches/#{model_name}_search_field"
    partial_rendered = ""
    content = form.fields_for(:criteria) do |f|
      f.fields_for(field.uuid) do |f|
        partial_rendered = render(partial, :f => f, :field => field)
      end
    end
    result = capture(content, &block)
    strip_tags(partial_rendered).blank? ? nil : result
  end
end
