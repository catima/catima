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
end
