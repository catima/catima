class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choices, :selected_choices_as_hash, :selected_choice?, :to => :field
  delegate :browse_similar_items_link_with_tooltip, :content_tag, :to => :view

  # rubocop:disable Layout/AlignParameters, Metrics/MethodLength
  def input(form, method)
    category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\"" : ''
    [
      '<div class="form-component">',
        "<div class=\"row\" #{category} data-choice-set=\"#{field.choice_set.id}\" data-field=\"#{field.id}\">",
          "<div class=\"col-xs-12\">",
                  form.label(field.label),
              "</div>",
          "</div>",
          "<div class=\"row choice-set-editor\" #{category} data-choice-set=\"#{field.choice_set.id}\" data-field=\"#{field.id}\">",
          '<div class="col-xs-8">',
            react_component('ChoiceSetEditor',
              props: {
                catalog: field.catalog.slug,
                itemType: field.item_type.slug,
                items: field.search_data_as_hash,
                searchPlaceholder: t('advanced_searches.fields.choice_set_search_field.select_placeholder'),
                srcId: "item_#{field.uuid}",
                srcRef: "item_#{field.uuid}",
                inputName: "item[#{field.uuid}_json]",
                inputDefaults: selected_choices_as_hash(@item),
                multiple: field.multiple?
              },
              prerender: false
            ),
          '</div>',
          '<div class="col-xs-4 btn-add-choiceset">',
            '<a class="btn btn-sm btn-default" style="color: #aaa;" data-toggle="modal" data-target="#choice-modal-'+method+'" href="#">',
              '<span class="glyphicon glyphicon-plus"></span>',
            '</a>',
          '</div>',
        '</div>',
      '</div>'
    ].join.html_safe
  end
  # rubocop:enable Layout/AlignParameters, Metrics/MethodLength

  def value
    choices = selected_choices(item)
    return if choices.empty?

    choices.map do |choice|
      value_slug = [I18n.locale, choice.short_name].join("-")
      tootltip_title = choice.top_parent_to_self.join(' > ')
      browse_similar_items_link_with_tooltip(
        choice.long_display_name, item, field, value_slug, tootltip_title
      )
    end.join(", ").html_safe
  end

  private

  # Add a data attribute to each option of the select to indicate which
  # category the choice is linked to, if any. This allows us to show and hide
  # appropriate fields in JavaScript based on the category.
  def options_for_select
    choices.map do |choice|
      data = {}
      data["choice-category"] = choice.category_id if choice.category_id

      content_tag(
        :option,
        choice.short_name,
        :value => choice.id,
        :selected => selected_choice?(item, choice),
        :data => data
      )
    end.join.html_safe
  end

  def choice_modal(method)
    field = Field.where(:uuid => method).first!
    ActionController::Base.new.render_to_string(
      :partial => 'catalog_admin/choice_sets/choice_modal',
      :locals => { field: field }
    )
  end
end
