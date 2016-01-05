class Field::ReferencePresenter < FieldPresenter
  delegate :references, :selected_references, :to => :field
  delegate :item_path, :link_to, :item_display_name, :to => :view

  def input(form, method, options={})
    form.collection_select(
      method,
      references,
      :id,
      method(:item_display_name),
      input_defaults(options),
      input_defaults(options)
    )
  end

  def value
    refs = selected_references(item)
    return if refs.empty?

    refs.map do |ref|
      link_to(
        item_display_name(ref),
        item_path(
          :catalog_slug => ref.catalog,
          :item_type_slug => ref.item_type,
          :locale => I18n.locale,
          :id => ref
        ))
    end.join(", ").html_safe
  end

  private

  # TODO: DRY up with ChoiceSetPresenter
  def input_defaults(options)
    super.reverse_merge(:include_blank => true, :multiple => field.multiple?)
  end

  def input_data_defaults(data)
    return super unless field.multiple?
    super.reverse_merge("select2-tagging" => true)
  end
end
