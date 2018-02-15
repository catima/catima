class Field::ReferencePresenter < FieldPresenter
  delegate :references, :selected_references, :to => :field
  delegate :select2_collection_select, :item_path, :link_to, :item_display_name,
           :to => :view

  def input(form, method, options={})
    field_category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\"" : ''
    [
      '<div class="form-component">',
      "<div #{field_category}>",
      select2_collection_select(
        form,
        method,
        references,
        :id,
        method(:item_display_name),
        input_defaults(options).merge(:multiple => field.multiple?)
      ),
      '</div>',
      '</div>'
    ].join.html_safe
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
