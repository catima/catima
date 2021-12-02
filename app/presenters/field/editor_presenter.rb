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
      [
        I18n.t('items.editor.created_by', editor: editor.email),
        (I18n.t('items.editor.at', date: I18n.l(item.created_at, format: 'YMDhm')) if timestamps_active?),
        ('<br>' if updater_active? && updater&.email.present?),
        (I18n.t('items.editor.updated_by', updater: updater&.email) if updater_active? && updater&.email.present?),
        (I18n.t('items.editor.at', date: I18n.l(item.updated_at, format: 'YMDhm')) if updater_active? && updater&.email.present? && timestamps_active?)
      ].join(' ')
    end
  end

  def field_value_for_item(item)
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
