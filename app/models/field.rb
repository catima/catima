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
    "text" => "Field::Text",
    "int" => "Field::Int",
    "decimal" => "Field::Decimal",
    "file" => "Field::File",
    "email" => "Field::Email",
    "url" => "Field::URL"
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
  validate :default_value_passes_field_validations
  validates_slug :scope => :item_type_id

  after_save :remove_primary_from_other_fields, :if => :primary?

  def self.sorted
    order("fields.position ASC, LOWER(fields.name) ASC")
  end

  def self.policy_class
    FieldPolicy
  end

  def self.type_choices
    Field::TYPES.map do |key, class_name|
      [key, class_name.constantize.new.type_name]
    end
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

  private

  # This can eventually be used to define validation rules for the dynamically-
  # generated Item class.
  def define_validators(field, attr)
    []
  end

  def default_value_passes_field_validations
    define_validators(self, :default_value).each do |validator|
      validator.validate(self)
    end
  end

  def remove_primary_from_other_fields
    item_type.fields.where("fields.id != ?", id).update_all(:primary => false)
  end
end
