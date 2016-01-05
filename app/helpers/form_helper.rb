module FormHelper
  def submit_and_add_another(form, options={})
    form.submit(
      "Create and add another",
      options.reverse_merge(
        "data-add-another" => true,
        "title" => "Keyboard shortcut: shift+enter"
      )
    )
  end

  # If multiple is true, add options that enable select2 JavaScript tagging and
  # autocomplete behavior. Then pass arguments through to the specified `select`
  # or `collection_select` form builder method.
  def with_select2_options(form, select_method, *args, &block)
    options = args.extract_options!
    multi = options[:multiple]
    return form.public_send(select_method, *args, options, &block) unless multi

    options = options.merge(
      :data => options.fetch(:data, {}).merge("select2-tagging" => true)
    )
    form.public_send(select_method, *args, options, options, &block)
  end
end
