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

class Field::Int < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum
  store_accessor :options, :auto_increment

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :allow_blank => true
  after_save :remove_default_value, :if => :auto_increment?

  def custom_field_permitted_attributes
    %i(maximum minimum auto_increment)
  end

  def order_items_by(direction: 'ASC', nulls_order: 'LAST')
    "NULLIF(items.data->>'#{uuid}', '')::BIGINT #{direction} NULLS #{nulls_order}"
  end

  def auto_increment?
    (options && options['auto_increment'] && options['auto_increment'].to_i) == 1
  end

  # Useful for the advanced search
  def search_conditions_as_options
    [
      [I18n.t("advanced_searches.number_search_field.contains_number"), "exact"],
      [I18n.t("advanced_searches.number_search_field.less_than"), "less_than"],
      [I18n.t("advanced_searches.number_search_field.less_than_or_equal_to"), "less_than_or_equal_to"],
      [I18n.t("advanced_searches.number_search_field.greater_than"), "greater_than"],
      [I18n.t("advanced_searches.number_search_field.greater_than_or_equal_to"), "greater_than_or_equal_to"]
    ]
  end

  def search_conditions_as_hash(locale)
    [
      {
        :value => I18n.t("advanced_searches.number_search_field.contains_number", locale: locale),
        :key => "exact"
      },
      {
        :value => I18n.t("advanced_searches.number_search_field.less_than", locale: locale),
        :key => "less_than"
      },
      {
        :value => I18n.t("advanced_searches.number_search_field.less_than_or_equal_to", locale: locale),
        :key => "less_than_or_equal_to"
      },
      {
        :value => I18n.t("advanced_searches.number_search_field.greater_than", locale: locale),
        :key => "greater_than"
      },
      {
        :value => I18n.t("advanced_searches.number_search_field.greater_than_or_equal_to", locale: locale),
        :key => "greater_than_or_equal_to"
      }
    ]
  end

  def sql_type
    "INT"
  end

  private

  def build_validators
    [numericality_validator]
  end

  def numericality_validator
    opts = { :allow_blank => true, :only_integer => true }
    opts[:less_than_or_equal_to] = maximum.to_i unless maximum.blank?
    opts[:greater_than_or_equal_to] = minimum.to_i unless minimum.blank?
    [ActiveModel::Validations::NumericalityValidator, opts]
  end
end
