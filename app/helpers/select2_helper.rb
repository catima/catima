module Select2Helper
  # See with_select2_options
  def select2_select(form, *args, &block)
    with_select2_options(form, :select, *args, &block)
  end

  # See with_select2_options
  def select2_collection_select(form, *args, &block)
    with_select2_options(form, :collection_select, *args, &block)
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
