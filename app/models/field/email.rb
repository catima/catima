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

class Field::Email < ::Field
  def sql_type
    "VARCHAR(255)"
  end

  private

  def build_validators
    [email_validator]
  end

  # Validates email fields. This is a modified version of the Regex used by Devise (Devise.email_regexp);
  # it additionnally verifies if there is a dot in the domain which is required for non-local emails.
  def email_validator
    [
      ActiveModel::Validations::FormatValidator,
      {
        :allow_blank => true,
        :with => /\A[^@\s]+@[^@\s]+\.(\S+)\z/,
        :message => :invalid_email
      }
    ]
  end
end
