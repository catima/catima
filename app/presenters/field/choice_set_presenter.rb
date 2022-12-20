class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choices, :selected_choice?, :choice_prefixed_label, :flat_ordered_choices, :to => :field
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ItemsHelper
  include Select2Helper

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
end
