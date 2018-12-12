class Field::ReferencePresenter < FieldPresenter
  delegate :references, :selected_references, :to => :field
  delegate :item_path, :link_to, :item_display_name,
           :to => :view

  def input(form, method, options={})
    [
      form.text_area(
        "#{method}_json",
        input_defaults(options).reverse_merge(
          "data-multiple": field.multiple?,
          "class": 'hidden'
        )
      ),
      reference_control(method)
    ].join.html_safe
  end

  def reference_control(method)
    react_component(
      'ReferenceEditor',
      props: {
        srcRef: "item_#{method}_json",
        srcId: method,
        multiple: field.multiple,
        req: field.required,
        category: field.category_id,
        catalog: field.catalog.slug,
        itemType: field.related_item_type.slug,
        locale: I18n.locale,
        noOptionsMessage: t('catalog_admin.items.reference_editor.no_options')
      },
      prerender: false
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
