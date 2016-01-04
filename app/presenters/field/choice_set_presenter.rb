class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choices, :selected_choice?, :to => :field
  delegate :browse_similar_items_link, :content_tag, :to => :view

  def input(form, method, options={})
    form.select(
      method,
      nil,
      input_defaults(options),
      input_defaults(options),
      &method(:options_for_select)
    )
  end

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

  def input_defaults(options)
    super.reverse_merge(:include_blank => true, :multiple => field.multiple?)
  end

  def input_data_defaults(data)
    return super unless field.multiple?
    super.reverse_merge("select2-tagging" => true)
  end


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
end
