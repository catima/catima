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

class Field::Int < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :allow_blank => true

  def custom_permitted_attributes
    %i(maximum minimum)
  end

  private

  def define_validators(field, attr)
    [numericality_validator(field, attr)]
  end

  def numericality_validator(field, attr)
    opts = { :attributes => attr, :allow_blank => true, :only_integer => true }
    max = field.maximum
    min = field.minimum
    opts[:less_than_or_equal_to] = max.to_i unless max.blank?
    opts[:greater_than_or_equal_to] = min.to_i unless min.blank?
    ActiveModel::Validations::NumericalityValidator.new(opts)
  end
end
