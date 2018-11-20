class Field::EditorPresenter < FieldPresenter
  delegate :user, :selected_user, :to => :field
  delegate :admin_user_path, :link_to, :to => :view

  def input(form, method, options={})
    editor = field.original_editor(item.creator_id)
    form.text_field(method, input_defaults(options).reverse_merge(:help => help, :value => editor.email, :readonly => true))
  end

  def value
    editor = field.original_editor(item.creator_id)

    if options.key?(:style) && options[:style] == :compact
      editor.email
    else
      updater = field.original_editor(item.updater_id)

      @view.render('fields/editor',
                   field: field,
                   editor: editor.email,
                   show_updater: updater_active?,
                   updater: updater&.email,
                   show_timestamps: timestamps_active?,
                   created_at: item.created_at,
                   updated_at: item.updated_at)
    end
  end

  def field_value_for_item(it)
    editor = field.original_editor(item.creator_id)
    editor.email
  end

  private

  def updater_active?
    return false unless field.options
    return false unless field.options.key?("updater")

    !field.options["updater"].to_i.zero?
  end

  def timestamps_active?
    return false unless field.options
    return false unless field.options.key?("timestamps")

    !field.options["timestamps"].to_i.zero?
  end
end
