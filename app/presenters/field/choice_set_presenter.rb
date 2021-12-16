class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choices, :selected_choice?, :choice_prefixed_label, :flat_ordered_choices, :to => :field
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ItemsHelper
  include Select2Helper

  # rubocop:disable Style/StringConcatenation
  def input(form, method, options={})
    # rubocop:disable Layout/LineLength
    category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\" data-field-category-choice-id=\"#{field.category_choice.id}\" data-field-category-choice-set-id=\"#{field.category_choice_set.id}\"" : ""
    # rubocop:enable Layout/LineLength

    choice_modal = [
      '<div class="col-sm-4" style="padding-top: 30px; margin-left: -15px;">',
        '<a class="btn btn-sm btn-outline-secondary" style="color: #aaa;" data-toggle="modal" data-target="#choice-modal-' + method + '" href="#">',
          '<i class="fa fa-plus"></i>',
        '</a>',
      '</div>'
    ]

    [
      '<div class="form-component">',
        "<div class=\"row\" #{category} data-choice-set=\"#{field.choice_set.id}\" data-field=\"#{field.id}\">",
          '<div class="col-sm-8">',
            select2_select(
              form,
              method,
              nil,
              input_defaults(options).merge(:multiple => field.multiple?, data: { choice_set_id: field.choice_set.id }),
              &method(:options_for_select)
            ),
          '</div>',
          (choice_modal if options[:current_user].catalog_role_at_least?(options[:catalog], "super-editor")),
        '</div>',
      '</div>'
    ].join.html_safe
  end
  # rubocop:enable Style/StringConcatenation

  def value
    choices = selected_choices(item)
    return if choices.empty?

    links_and_prefixed_names = choices.map do |choice|
      value_slug = [I18n.locale, choice.short_name].join("-")
      [
        browse_similar_items_link(
          choice.long_display_name, item, field, value_slug
        ),
        browse_similar_items_link(
          choice_prefixed_label(choice, format: :long), item, field, value_slug
        ),
        choice_prefixed_label(choice, format: :long)
      ]
    end

    if links_and_prefixed_names.size >= 1 && options[:style] != :compact
      tag.div(
        links_and_prefixed_names.map do |link, prefixed_link|
          tag.div(
            tag.div(link + (if link != prefixed_link
                              tag.span(tag.i(class: "fa fa-caret-right toggle-hierarchy"), class: 'pl-2', 'data-toggle': "tooltip", title: t('catalog_admin.choice_sets.choice.show_hierarchy'), 'data-action': "click->hierarchy-revealable#toggle")
                            end), 'data-hierarchy-revealable-target': 'choice') +
              tag.div(prefixed_link + tag.span(tag.i(class: "fa fa-caret-left toggle-hierarchy"), class: 'pl-2', 'data-toggle': "tooltip", title: t('catalog_admin.choice_sets.choice.hide_hierarchy'), 'data-action': "click->hierarchy-revealable#toggle"), 'data-hierarchy-revealable-target': 'choice', style: 'display: none'),
            'data-controller': "hierarchy-revealable"
          )
        end.join(" ").html_safe
      )
    else
      links_and_prefixed_names.map(&:first).join(", ").html_safe
    end
  end

  private

  # Add a data attribute to each option of the select to indicate which
  # category the choice is linked to, if any. This allows us to show and hide
  # appropriate fields in JavaScript based on the category.
  def options_for_select
    choices = !field.choice_set.not_deleted? || !field.choice_set.not_deactivated? ? [] : flat_ordered_choices
    choices.map do |choice|
      data = {}
      data["choice-category"] = choice.category_id if choice.category_id
      data["choice-id"] = choice.id if choice.category_id
      data["choice-set-id"] = choice.choice_set.id if choice.category_id

      tag.option(
        choice_prefixed_label(choice),
        :value => choice.id,
        :selected => selected_choice?(item, choice),
        has_childrens: choice.childrens.any?,
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
