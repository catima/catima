# == Schema Information
#
# Table name: fields
#
#  category_item_type_id :integer
#  choice_set_id         :integer
#  comment               :text
#  created_at            :datetime         not null
#  default_value         :text
#  display_in_list       :boolean          default(TRUE), not null
#  i18n                  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  item_type_id          :integer
#  multiple              :boolean          default(FALSE), not null
#  name                  :string
#  name_plural           :string
#  options               :json
#  ordered               :boolean          default(FALSE), not null
#  position              :integer          default(0), not null
#  primary               :boolean          default(FALSE), not null
#  related_item_type_id  :integer
#  required              :boolean          default(TRUE), not null
#  row_order             :integer
#  slug                  :string
#  type                  :string
#  unique                :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#

class Field::Reference < ::Field
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

  def custom_permitted_attributes
    %i(related_item_type_id)
  end
end
