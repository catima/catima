# == Schema Information
#
# Table name: advanced_searches
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  creator_id   :integer
#  criteria     :json
#  id           :integer          not null, primary key
#  item_type_id :integer
#  locale       :string           default("en"), not null
#  updated_at   :datetime         not null
#  uuid         :string
#

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
  def render_advanced_search_field(form, field, index, &block)
    model_name = field.partial_name
    partial = "advanced_searches/fields/#{model_name}_search_field"
    partial_rendered = ""
    content = form.fields_for(:criteria) do |f|
      f.fields_for(field.uuid) do |f|
        begin
          partial_rendered = render(partial, :f => f, :field => field, :i => index)
        rescue ActionView::MissingTemplate
          partial_rendered = nil
        end
      end
    end
    result = capture(content, &block)
    partial_rendered.present? ? result : partial_rendered
  end

  def render_item_types_as_options(item_types, selected_item_type_slug)
    options = []
    item_types.each do |item_type|
      options << [
        item_type.name,
        item_type.slug,
        :selected => item_type.slug == selected_item_type_slug,
        "data-has-map" => item_type.include_geographic_field?
      ]
    end

    options
  end

  def render_and_or_exclude_select(form)
    form.select(
      "field_condition",
      [
        [I18n.t(".and"), "and"],
        [I18n.t(".or"), "or"],
        [I18n.t(".exclude"), "exclude"]
      ],
      { :hide_label => true },
      :class => "field-condition"
    )
  end
end
