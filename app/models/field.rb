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

# rubocop:disable Metrics/ClassLength
class Field < ApplicationRecord
  TYPES = {
    "boolean" => "Field::Boolean",
    "choice" => "Field::ChoiceSet",
    "datetime" => "Field::DateTime",
    "decimal" => "Field::Decimal",
    "email" => "Field::Email",
    "editor" => "Field::Editor",
    "file" => "Field::File",
    "geometry" => "Field::Geometry",
    "image" => "Field::Image",
    "int" => "Field::Int",
    "reference" => "Field::Reference",
    "text" => "Field::Text",
    "url" => "Field::URL",
    "xref" => "Field::Xref"
  }.freeze

  include ActionView::Helpers::SanitizeHelper
  include Field::Style
  include HasTranslations
  include HasSlug
  include HasSqlSlug
  include RankedModel
  include FieldsHelper
  include JsonHelper

  ranks :row_order, :class_name => "Field", :with_same => :field_set_id

  delegate :catalog, :to => :field_set, :allow_nil => true
  delegate :component_choice?, :components_are_valid, :component_choices,
           :assign_default_components,
           :to => :component_config

  belongs_to :field_set, :polymorphic => true

  store_translations :name, :name_plural

  validates_presence_of :field_set
  validate :default_value_passes_field_validations
  validate :components_are_valid
  validates_slug :scope => :field_set_id

  before_validation :assign_default_components
  before_create :assign_uuid
  after_save :remove_primary, :if => :primary?

  def self.sorted
    rank(:row_order)
  end

  def self.policy_class
    FieldPolicy
  end

  def self.type_choices
    Field::TYPES.map do |key, class_name|
      [key, class_name.constantize.new.type_name]
    end.sort_by(&:last)
  end

  alias_method :item_type, :field_set

  def belongs_to_category?
    !!category_id
  end

  # Whether or not a field is displayable to a user for a specific catalog.
  #
  # A restricted field should not be displayed if the user is not a staff
  # (>= editor) of the current catalog
  def displayable_to_user?(user, cat=catalog)
    at_least_editor = user.catalog_role_at_least?(cat, 'editor')
    at_least_editor || !restricted?
  end

  def category_id
    field_set.is_a?(Category) ? field_set.id : nil
  end

  def type_name
    type.gsub(/Field::/, "")
  end

  def short_type_name
    ::Field::TYPES.to_a.rassoc(self.class.to_s).first
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

  def label
    multiple? ? name_plural : name
  end

  # Whether or not this field holds a human-readable value, e.g. text, number,
  # etc. An image or geometry would not qualify, as those are displayed as non-
  # text. Any field that uses a display_component would not qualify, because the
  # field is rendered via JavaScript.
  #
  # Default depends on the presence of display_component, and subclasses can
  # override.
  #
  def human_readable?
    display_component.blank?
  end

  # Whether or not this field is filterable.
  #
  # Default depends on the presence of the human_readable method result, and subclasses can
  # override.
  #
  # Mainly used by advanced search components, also used by views for the item summary.
  def filterable?
    human_readable?
  end

  # Whether or not this field supports the `multiple` option. Most fields do
  # not. This method exists so that the UI can show or hide the appropriate
  # configuration controls for the field. Subclasses may override.
  def allows_multiple?
    false
  end

  # Whether or not this field supports the `style` options. Subclasses may override.
  def allows_style?
    true
  end

  # Whether or not this field supports the `unique` option. Subclasses may override.
  def allows_unique?
    true
  end

  def raw_value(item, locale=I18n.locale, suffix="")
    return nil unless applicable_to_item(item)

    attrib = i18n? ? "#{uuid}_#{locale}#{suffix}" : uuid
    item.behaving_as_type.public_send(attrib)
  end

  def raw_json_value(item, locale=I18n.locale)
    raw_value(item, locale, "_json")
  end

  # Takes the input value and tries to prepare value for setting the field.
  # This can be a localized hash, or a hash describing a referenced item.
  # It returns a hash that can be used to update the item with the correct
  # field uuids.
  def prepare_value(value)
    {uuid => value}
  end

  # Returns additional properties for React for editing component
  def edit_props
    {}
  end

  # Returns additional properties for React for viewing component
  def view_props
    {}
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

  # Returns a JSON description of this field. By default, it returns all
  # attributes. Subclasses can override this method to provide a more
  # specific description.
  def describe
    as_json(only:
              %i[
                type uuid slug name_translations
                name_plural_translations comment default_value primary
                required unique options display_in_list display_in_public_list
              ]
           ).merge(allows_multiple? ? as_json(only: [:multiple]) : {})
  end

  # Returns the field value for a given item
  # For simple field types, it returns the database representation
  # For more complex field types, it returns the item type instance,
  # or another adapted representation. In this case, this method
  # is overridden by the field subclasses.
  def value_for_item(it)
    it.data[uuid]
  end

  def value_or_id_for_item(it)
    value_for_item(it)
  end

  def field_value_for_item(it)
    raw_value(it) if human_readable?
  end

  # Even non readable. Useful for dumps
  def field_value_for_all_item(it)
    raw_value = raw_value(it)
    return raw_value unless is_a?(Field::File) || is_a?(Field::Image)

    # gsub is useful to change the path of uploaded files
    raw_value.to_s.gsub("upload/#{it.catalog.slug}", "files") unless raw_value.nil?
  end

  # Defines methods and runs class macros on the given item class in order to
  # add validation rules, accessors, etc. for this field. The class in this
  # case is an anonymous subclass of Item.
  def decorate_item_class(klass)
    klass.data_store_attribute(uuid, :i18n => i18n?, :multiple => multiple?, :transformer => method(:transform_value))

    # TODO: how does validation work for multi-valued?
    validators = build_validators
    validators << ActiveModel::Validations::PresenceValidator if required?

    validators.each do |val|
      val = Array.wrap(val)
      options = val.extract_options!
      klass.data_store_validator(uuid, val.first, options, :i18n => i18n?, :prerequisite => method(:applicable_to_item))
    end
  end

  # Remove html tags & base64 from field content
  def strip_extra_content(item, locale=I18n.locale)
    strip_tags(exclude_base64(raw_value(item, locale)))
  end

  # Returns the order by for items with a sort by a field
  def order_items_by
    # "data->>'#{uuid}' ASC"
    "items.data->>'#{uuid}' ASC"
  end

  # Useful for the advanced search
  def search_conditions_as_options
    [
      [I18n.t("advanced_searches.text_search_field.exact"), "exact"],
      [I18n.t("advanced_searches.text_search_field.all_words"), "all_words"],
      [I18n.t("advanced_searches.text_search_field.one_word"), "one_word"]
    ]
  end

  def search_conditions_as_hash(locale)
    [
      { :value => I18n.t("advanced_searches.text_search_field.exact", locale: locale), :key => "exact"},
      { :value => I18n.t("advanced_searches.text_search_field.all_words", locale: locale), :key => "all_words"},
      { :value => I18n.t("advanced_searches.text_search_field.one_word", locale: locale), :key => "one_word"}
    ]
  end

  def search_field_conditions_as_hash
    [
      { :value => I18n.t("and"), :key => "and"},
      { :value => I18n.t("or"), :key => "or"},
      { :value => I18n.t("exclude"), :key => "exclude"}
    ]
  end

  def search_data_as_hash
  end

  def search_options_as_hash
  end

  private

  def exclude_base64(string)
    return '' if string.blank?
    return '' unless string.instance_of? String

    string.gsub(%r{data:image/([a-zA-Z]*);base64,([^\"]*)\"}, '')
  end

  def component_config
    @_component_config ||= ComponentConfig.new(self)
  end

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

  def remove_primary
    # Remove primary if current field is not human readable
    return update(:primary => false) unless human_readable?

    # Remove primary from other fields if current field is human readable
    field_set.fields.where("fields.id != ?", id).update_all(:primary => false)
  end

  def remove_default_value
    update(:default_value => nil) if default_value?
  end

  def transform_value(value)
    value
  end
end
# rubocop:enable Metrics/ClassLength
