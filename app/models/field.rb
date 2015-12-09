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

# TODO: drop name_old and name_plural_old columns (no longer used)
class Field < ActiveRecord::Base
  TYPES = {
    "text" => "Field::Text",
    "int" => "Field::Int",
    "decimal" => "Field::Decimal",
    "datetime" => "Field::DateTime",
    "image" => "Field::Image",
    "file" => "Field::File",
    "email" => "Field::Email",
    "url" => "Field::URL",
    "choice" => "Field::ChoiceSet",
    "reference" => "Field::Reference",
    "xref" => "Field::Xref"
  }.freeze

  STYLE_CHOICES = {
    "single" => "Single value – optional",
    "single-required" => "Single value – required",
    "multiple" => "Multiple values – optional",
    "multiple-required" => "Multiple values – at least one",
    "multiple-ordered" => "Multiple ordered values – optional",
    "multiple-ordered-required" => "Multiple ordered values – at least one"
  }.freeze

  include HasTranslations
  include HasSlug
  include RankedModel

  ranks :row_order, :class_name => "Field", :with_same => :field_set_id

  delegate :catalog, :to => :field_set, :allow_nil => true

  belongs_to :field_set, :polymorphic => true

  store_translations :name, :name_plural

  validates_presence_of :field_set
  validate :default_value_passes_field_validations
  validates_slug :scope => :field_set_id

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

  alias_method :item_type, :field_set

  def belongs_to_category?
    !!category_id
  end

  def category_id
    field_set.is_a?(Category) ? field_set.id : nil
  end

  def type_name
    type.gsub(/Field::/, "")
  end

  def partial_name
    model_name.singular.sub(/^field_/, "")
  end

  def custom_field_permitted_attributes
    []
  end

  def custom_item_permitted_attributes
    []
  end

  def raw_value(item, locale=I18n.locale)
    return nil unless applicable_to_item(item)
    attrib = i18n? ? "#{uuid}_#{locale}" : uuid
    item.behaving_as_type.public_send(attrib)
  end

  # Tests whether this field is appropriate to display/validate for the given
  # item. This only makes sense for category fields. For non-category fields,
  # always returns true.
  def applicable_to_item(item)
    return true unless belongs_to_category?

    item.fields.any? do |field|
      next unless field.is_a?(ChoiceSet)
      choice = field.selected_choice(item)
      choice && choice.category_id == category_id
    end
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
    klass.data_store_attribute(uuid, :i18n => i18n?, :multiple => multiple?)

    # TODO: how does validation work for multi-valued?
    validators = build_validators
    validators << ActiveModel::Validations::PresenceValidator if required?

    validators.each do |val|
      val = Array.wrap(val)
      options = val.extract_options!
      klass.data_store_validator(
        uuid,
        val.first,
        options,
        :i18n => i18n?,
        :prerequisite => method(:applicable_to_item)
      )
    end
  end

  private

  def build_validators
    []
  end

  def default_value_passes_field_validations
    build_validators.each do |val|
      val = Array.wrap(val)
      options = val.extract_options!
      validates_with(val.first, options.merge(:attributes => :default_value))
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
    field_set.fields.where("fields.id != ?", id).update_all(:primary => false)
  end
end
