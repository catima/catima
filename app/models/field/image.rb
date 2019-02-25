require_dependency("field/file")
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

# An image is indistinguishable on the back end from a generic file, but it is
# a distinct field type so that we can display it differently in the UI.
class Field::Image < ::Field::File
  store_accessor :options, :legend

  after_initialize :set_default_types

  def human_readable?
    false
  end

  def allows_unique?
    false
  end

  def custom_field_permitted_attributes
    %i(legend)
  end

  def field_value_for_all_item(item)
    value = super

    case
    when value.is_a?(Hash)
      return "" if value["path"].blank?

      img = { :path => value["path"] }
      img[:legend] = value["legend"] if value["legend"].present?

      return img.to_json
    when value.is_a?(Array)
      value.map do |i|
        next if i["path"].blank?

        img = { :path => i["path"] }
        img[:legend] = i["legend"] if i["legend"].present?

        img.to_json
      end
    end
  end

  def sql_type
    "VARCHAR(255)"
  end

  private

  def set_default_types
    return if persisted? || types.present?

    self.types = "jpg, jpeg, png, gif"
  end
end
