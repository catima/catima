# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_in_list          :boolean          default(TRUE), not null
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  multiple                 :boolean          default(FALSE), not null
#  name_old                 :string
#  name_plural_old          :string
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

module FieldsHelper
  def field_help_text(field, _attribute=:default_value)
    model_key = field.model_name.i18n_key
    t("helpers.help.#{model_key}")
  end

  def field_value(item, field, options={})
    presenter = field_presenter(item, field, options)

    if presenter.field.display_component.present?
      json_react_display_component(item, presenter.field, field.view_props)
    else
      presenter.value
    end
  end

  # Returns a boolean value whether the field should be displayed or not.
  # Option to hide or show empty fields is available in the catalog admin
  # item type edition view.
  def field_check_display(item, field)
    return true if item.item_type.display_emtpy_fields

    if %w[Field::Geometry Field::File Field::Image Field::Embed].include?(field.type)
      field_presenter(item, field).value?
    else
      strip_tags(field_value(item, field)).present?
    end
  end

  def field_presenter(item, field, options={})
    field = resolve_field(item.try(:item_type), field)
    "#{field.class.name}Presenter".constantize.new(self, item, field, options)
  end

  # Returns all items of the given type that reference an item by a certain
  # field. For example, assuming a :books item type that has an :author
  # reference field, and `item` is an author, then:
  #
  #   field_item_references(:books, :author, item)
  #
  # returns an ItemList::References object containing all the books that point
  # to that author.
  #
  # Item types and fields can be specified by slug or by the actual ItemType or
  # Field object. If a block is given, the resulting item list will be yielded
  # to the block, but only if the item list is not empty.
  #
  def field_item_references(type, field, item)
    type = resolve_type(type)
    field = resolve_field(type, field)
    list = ItemList::References.new(:item => item, :field => field)
    yield(list) if block_given? && !list.empty?
    list
  end

  def fields_and_item_references(item)
    item.referenced_by_fields.each_with_object({}) do |field, result|
      # skip if we have a category
      next if field.item_type.is_a?(Category)

      # skip if item type is inactive
      next unless field.item_type.not_deleted?

      list = field_item_references(field.item_type, field, item)
      next if list.empty?

      result[field] = list
      yield(field, list) if block_given?
    end
  end

  # Clean the type name of the field to match translation strings
  # The parameter can be either a Field instance or a non-cleaned field type_name string
  def translation_type_name(field)
    field = field.type.constantize.new.type_name if field.is_a?(Field)
    field.sub(' ', '_').downcase
  end

  private

  def resolve_type(item_type_or_slug)
    return item_type_or_slug if item_type_or_slug.is_a?(ItemType)

    catalog.item_types.find(-> { fail "Unknown type: #{item_type_slug}"}) do |t|
      t.slug == item_type_or_slug.to_s
    end
  end

  def resolve_field(item_type, field_or_slug)
    return field_or_slug if field_or_slug.is_a?(Field)

    item_type.fields.find(-> { fail "Unknown field: #{field_or_slug}" }) do |f|
      f.slug == field_or_slug.to_s
    end
  end

  # Returns all applicable fields for the item
  def item_applicable_fields(item)
    displayable_fields(item.applicable_fields)
  end

  # Returns all displayable fields for a collection of fields without the restricted ones
  def displayable_fields(fields)
    fields.select do |fld|
      fld.displayable_to_user?(current_user)
    end
  end
end
