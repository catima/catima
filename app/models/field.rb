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
#  primary               :boolean          default(FALSE), not null
#  related_item_type_id  :integer
#  required              :boolean          default(TRUE), not null
#  row_order             :integer
#  slug                  :string
#  type                  :string
#  unique                :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#  uuid                  :string
#

class Field < ActiveRecord::Base
  TYPES = {
    "text" => "Field::Text",
    "int" => "Field::Int",
    "decimal" => "Field::Decimal",
    "file" => "Field::File",
    "email" => "Field::Email",
    "url" => "Field::URL",
    "choice" => "Field::ChoiceSet",
    "reference" => "Field::Reference",
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
  include RankedModel

  ranks :row_order, :class_name => "Field", :with_same => :item_type_id

  delegate :catalog, :to => :item_type

  belongs_to :item_type

  validates_presence_of :item_type
  validates_presence_of :name
  validates_presence_of :name_plural
  validate :default_value_passes_field_validations
  validates_slug :scope => :item_type_id

  before_create :assign_uuid
  after_save :remove_primary_from_other_fields, :if => :primary?

  def self.sorted
    rank(:row_order)
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

  def partial_name
    model_name.singular.sub(/^field_/, "")
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

  # Defines methods and runs class macros on the given item class in order to
  # add validation rules, accessors, etc. for this field. The class in this
  # case is an anonymous subclass of Item.
  def decorate_item_class(klass)
    define_accessor(klass)

    validators = build_validators(uuid)
    klass.send(:validate) do |item|
      validators.each { |v| v.validate(item) }
    end

    klass.send(:validates_presence_of, uuid) if required?
  end

  def read_value(item)
    data_store(item).get
  end

  def write_value(item, value)
    data_store(item).set(value)
  end

  private

  def build_validators(attr)
    []
  end

  def define_accessor(klass)
    # TODO: accessor per locale?
    field = self
    klass.send(:define_method, uuid) { field.read_value(self) }
    klass.send(:define_method, "#{uuid}=") { |v| field.write_value(self, v) }
  end

  def data_store(item, locale=I18n.locale)
    item.data ||= {}
    Item::DirtyAwareDataStore.new(
      :item => item,
      :key => uuid,
      :multivalued => multiple?,
      :locale => (i18n? ? locale : nil)
    )
  end

  def default_value_passes_field_validations
    build_validators(:default_value).each do |validator|
      validator.validate(self)
    end
  end

  # Used as the key in the `data` JSON to store the value for this field.
  # For compatibility with third-party gems (e.g. refile), it has to be valid
  # as a Ruby instance variable name (letters, numbers, underscores; can't
  # start with a number).
  def assign_uuid
    self.uuid ||= "_#{SecureRandom.uuid.tr('-', '_')}"
  end

  def remove_primary_from_other_fields
    item_type.fields.where("fields.id != ?", id).update_all(:primary => false)
  end
end
