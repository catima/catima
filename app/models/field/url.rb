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

class Field::URL < Field
  def sql_value(item)
    value = value_for_item(item)
    return unless value

    return value['_translations'].to_json.to_s.gsub("'") { "\\'" } if i18n?

    value.to_s.gsub("'") { "\\'" }
  end

  def sql_type
    return "JSON" if i18n?

    "VARCHAR(512)"
  end

  def groupable?
    false
  end

  private

  def build_validators
    [url_validator]
  end

  def url_validator
    [
      ActiveModel::Validations::FormatValidator,
      { :allow_blank => true, :with => URI.regexp, :message => :invalid_url }
    ]
  end
end
