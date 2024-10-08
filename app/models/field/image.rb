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
class Field::Image < Field::File
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

  # Max upload image size (in MB). Default is 15MB.
  def max_file_size
    ENV["IMAGE_MAX_UPLOAD_SIZE"].present? ? Integer(ENV["IMAGE_MAX_UPLOAD_SIZE"]) : 15
  end

  def sql_value(item)
    value = raw_value(item)

    images = []
    if value.is_a?(Hash) && value["path"].present?
      images = add_image_hash(images, value, item)
    elsif value.is_a?(Array) && value.present?
      value.map do |i|
        next if i["path"].blank?

        images = add_image_hash(images, i, item)
      end
    end

    images.to_json.gsub("'") { "\\'" }
  end

  def sql_type
    "JSON"
  end

  def displayable_in_public_list?
    true
  end

  private

  def set_default_types
    return if persisted? || types.present?

    self.types = "jpg, jpeg, png, gif"
  end

  def add_image_hash(images, image, item)
    format_path_for_export(image["path"], item)
    img = { :path => image["path"] }
    img[:legend] = image["legend"].gsub("\"") { "\\\"" } if image["legend"].present?

    images << img
  end
end
