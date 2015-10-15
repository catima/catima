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

class Field::Text < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_blank => true

  # TODO: move this to superclass?
  validate :default_value_passes_field_validations

  # This can eventually be used to define validation rules for the dynamically-
  # generated Item class.
  def define_validators(field, attr)
    [length_validator(field, attr)].compact
  end

  def custom_permitted_attributes
    %i(maximum minimum)
  end

  private

  def default_value_passes_field_validations
    define_validators(self, :default_value).each do |validator|
      validator.validate(self)
    end
  end

  def length_validator(field, attr)
    opts = { :attributes => attr, :allow_blank => true }
    opts[:maximum] = field.maximum.to_i if field.maximum.to_i > 0
    opts[:minimum] = field.minimum.to_i if field.minimum.to_i > 0
    ActiveModel::Validations::LengthValidator.new(opts) if opts.size > 2
  end
end
