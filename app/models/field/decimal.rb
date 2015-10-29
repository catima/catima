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
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  item_type_id             :integer
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

class Field::Decimal < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum, :allow_blank => true

  def custom_permitted_attributes
    %i(maximum minimum)
  end

  private

  def build_validators
    [numericality_validator]
  end

  def numericality_validator
    opts = { :allow_blank => true }
    opts[:less_than_or_equal_to] = maximum.to_i unless maximum.blank?
    opts[:greater_than_or_equal_to] = minimum.to_i unless minimum.blank?
    [ActiveModel::Validations::NumericalityValidator, opts]
  end
end
