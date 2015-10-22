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

class Field::Text < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_blank => true

  def custom_permitted_attributes
    %i(maximum minimum)
  end

  private

  def build_validators(attr)
    [length_validator(attr)].compact
  end

  def length_validator(attr)
    opts = { :attributes => attr, :allow_blank => true }
    opts[:maximum] = maximum.to_i if maximum.to_i > 0
    opts[:minimum] = minimum.to_i if minimum.to_i > 0
    ActiveModel::Validations::LengthValidator.new(opts) if opts.size > 2
  end
end
