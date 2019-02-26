# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_component        :string
#  display_in_list          :boolean          default(TRUE), not null
#  display_in_public_list   :boolean          default(TRUE), not null
#  editor_component         :string
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  multiple                 :boolean          default(FALSE), not null
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  restricted               :boolean          default(FALSE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

class Field::Reference < ::Field
  include ::Field::AllowsMultipleValues

  belongs_to :related_item_type, :class_name => "ItemType"

  validates_presence_of :related_item_type
  validates_inclusion_of :related_item_type,
                         :in => :related_item_type_choices,
                         :allow_nil => true

  def type_name
    super + (related_item_type ? " (#{related_item_type.name})" : "")
  end

  def related_item_type_choices
    catalog.item_types.sorted
  end

  def custom_field_permitted_attributes
    %i(related_item_type_id)
  end

  def references
    return Item.none if related_item_type.nil?

    related_item_type.sorted_items
  end

  def selected_references(item)
    return [] if raw_value(item).blank?

    references.where(:id => raw_value(item))
  end

  def filterable?
    false
  end

  def describe
    super.merge("related_item_type": related_item_type.slug)
  end

  def prepare_value(value)
    k = value.keys[0]
    v = value[k]
    v = v.sub("'", "''") if v.is_a?(String)
    i = related_item_type.items.where("data->>'#{uuid}'='#{v}'").first
    {uuid => (i.id unless i.nil?)}
  end

  def value_for_item(it)
    multiple? ? selected_references(it) : selected_references(it).first
  end

  def value_or_id_for_item(it)
    refs = selected_references(it)
    if multiple?
      refs.map(&:uuid)
    else
      refs.first.nil? ? nil : refs.first.uuid
    end
  end

  def field_value_for_item(it)
    refs = value_for_item(it)
    if multiple?
      refs.map(&:default_display_name).join(', ')
    else
      refs.nil? ? nil : refs.default_display_name
    end
  end

  def order_items_by
    "(ref_items.data->>'#{related_item_type.field_for_select.uuid}') ASC" unless related_item_type.field_for_select.nil?
  end

  def search_conditions_as_hash
    []
  end

  def field_value_for_all_item(item)
    item_type.primary_text_field&.field_value_for_all_item(item)
  end

  def sql_type
    "INT"
    # return "INT" if related_item_type.primary_field.blank?
    #
    # related_item_type.primary_field.sql_type
    # while related_primary_field.is_a?(Field::Reference) && related_primary_field.related_item_type.present?
    #   related_primary_field = related_item_type.primary_field.sql_type
    # end
  end

  def search_conditions_as_hash
    []
  end

  def field_value_for_all_item(item)
    item_type.primary_text_field&.field_value_for_all_item(item)
  end

  def sql_type
    return "INT" if related_item_type.primary_field.blank?

    related_item_type.primary_field.sql_type
    # while related_primary_field.is_a?(Field::Reference) && related_primary_field.related_item_type.present?
    #   related_primary_field = related_item_type.primary_field.sql_type
    # end
  end
end
