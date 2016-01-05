class Field::ReferencePresenter < FieldPresenter
  delegate :references, :selected_references, :to => :field
  delegate :with_select2_options, :item_path, :link_to, :item_display_name,
           :to => :view

  def input(form, method, options={})
    with_select2_options(
      form,
      :collection_select,
      method,
      references,
      :id,
      method(:item_display_name),
      input_defaults(options).merge(:multiple => field.multiple?)
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
end
