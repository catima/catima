module FormHelper
  def submit_and_add_another(form, options={})
    form.submit(
      I18n.t('add_another'),
      options.reverse_merge(
        "data-add-another" => true,
        "title" => "Keyboard shortcut: shift+enter"
      )
    )
  end
end
