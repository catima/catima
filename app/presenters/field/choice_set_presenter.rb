class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choices, :selected_choice?, :to => :field
  delegate :select2_select, :browse_similar_items_link, :tag,
           :to => :view

  # rubocop:disable Style/StringConcatenation
  def input(form, method, options={})
    category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\"" : ''
    [
      '<div class="form-component">',
        "<div class=\"row\" #{category} data-choice-set=\"#{field.choice_set.id}\" data-field=\"#{field.id}\">",
          '<div class="col-sm-8">',
            select2_select(
              form,
              method,
              nil,
              input_defaults(options).merge(:multiple => field.multiple?),
              &method(:options_for_select)
            ),
          '</div>',
          '<div class="col-sm-4" style="padding-top: 30px; margin-left: -15px;">',
            '<a class="btn btn-sm btn-outline-secondary" style="color: #aaa;" data-toggle="modal" data-target="#choice-modal-'+method+'" href="#">',
              '<i class="fa fa-plus"></i>',
            '</a>',
          '</div>',
        '</div>',
      '</div>'
    ].join.html_safe
  end
  # rubocop:enable Style/StringConcatenation

  def value
    choices = selected_choices(item)
    return if choices.empty?

    choices.map do |choice|
      value_slug = [I18n.locale, choice.short_name].join("-")
      browse_similar_items_link(
        choice.long_display_name, item, field, value_slug
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

      tag.option(
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
