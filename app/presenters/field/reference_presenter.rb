class Field::ReferencePresenter < FieldPresenter
  include ActionView::Helpers
  include ItemsHelper
  include FieldsHelper

  delegate :references, :selected_references, :to => :field

  def input(form, method, options={})
    [
      form.text_area(
        "#{method}_json",
        input_defaults(options).reverse_merge(
          'data-multiple': field.multiple?,
          class: 'd-none'
        )
      ),
      reference_control(method)
    ].join.html_safe
  end

  def reference_control(method)
    # rubocop:disable Layout/LineLength
    category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\" data-field-category-choice-id=\"#{field.category_choice.id}\" data-field-category-choice-set-id=\"#{field.category_choice_set.id}\"" : ""
    # rubocop:enable Layout/LineLength
    [
      '<div class="form-component">',
      "<div class=\"row\" #{category} data-field=\"#{field.id}\">",
      '<div class="col-sm-12">',
      component(method),
      '</div>',
      '</div>',
      '</div>'
    ].join.html_safe
  end

  def component(method)
    react_component(
      'ReferenceEditor/components/ReferenceEditor',
      {
        srcRef: "item_#{method}_json",
        srcId: method,
        selectedReferences: selected_references(item).map { |item| item.describe([:default_display_name], [], true) },
        multiple: field.multiple,
        req: field.required,
        category: field.category_id,
        catalog: field.catalog.slug,
        itemType: field.related_item_type.slug,
        locale: I18n.locale,
        noOptionsMessage: t('catalog_admin.items.reference_editor.no_options')
      }
    )
  end

  def value
    refs = selected_references(item)
    return if refs.empty?

    refs.map do |ref|
      link_to(
        item_display_name(ref),
        Rails.application.routes.url_helpers.item_path(
          :catalog_slug => ref.catalog,
          :item_type_slug => ref.item_type,
          :locale => I18n.locale,
          :id => ref
        ))
    end.join(", ").html_safe
  end
end
