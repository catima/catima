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

class Field::Email < ::Field
  private

  def define_validators(field, attr)
    [email_validator(field, attr)]
  end

  def email_validator(_field, attr)
    ActiveModel::Validations::FormatValidator.new(
      :attributes => attr,
      :allow_blank => true,
      :with => Devise.email_regexp,
      :message => :invalid_email
    )
  end
end
