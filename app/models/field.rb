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
#  slug                  :string
#  type                  :string
#  unique                :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#

class Field < ActiveRecord::Base
  TYPES = {
    "text" => "Field::Text"
  }.freeze

  STYLE_CHOICES = {
    "single" => "Single value – optional",
    "single-required" => "Single value – required",
    "multiple" => "Multiple values – optional",
    "multiple-required" => "Multiple values – at least one",
    "multiple-ordered" => "Multiple ordered values – optional",
    "multiple-ordered-required" => "Multiple ordered values – at least one"
  }.freeze

  include HasSlug

  delegate :catalog, :to => :item_type

  belongs_to :item_type
  belongs_to :category_item_type, :class_name => "ItemType"
  belongs_to :related_item_type, :class_name => "ItemType"
  belongs_to :choice_set

  validates_presence_of :item_type
  validates_presence_of :name
  validates_presence_of :name_plural
  validates_slug :scope => :item_type_id

  def self.sorted
    order("fields.position ASC, LOWER(fields.name) ASC")
  end

  def self.policy_class
    FieldPolicy
  end

  def type_name
    type.gsub(/Field::/, "")
  end

  def custom_permitted_attributes
    []
  end

  # TODO: test
  def style=(key)
    return if key.blank?
    self.required = !!(key =~ /required/)
    self.multiple = !!(key =~ /multiple/)
    self.ordered = !!(key =~ /ordered/)
  end

  def style
    key = []
    key << (multiple? ? "multiple" : "single")
    key << "ordered" if multiple? && ordered?
    key << "required" if required?
    key.join("-")
  end
end
