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

class Field::File < ::Field
  include ::Field::AllowsMultipleValues

  store_accessor :options, :types

  validates_presence_of :types

  def custom_field_permitted_attributes
    %i(types)
  end

  def allowed_extensions
    types.to_s.split(/[,\s]+/).map do |token|
      token.strip[/^\.?(\S+)/, 1]
    end
  end

  # Max upload file size (in MB). Default is 200MB.
  # Subclasses can override this method.
  def max_file_size
    ENV["FILE_MAX_UPLOAD_SIZE"].present? ? Integer(ENV["FILE_MAX_UPLOAD_SIZE"]) : 200
  end

  def file_count(item)
    files = raw_value(item)
    return 0 if files.nil?

    files.is_a?(Array) ? files.count : 1
  end

  def human_readable?
    false
  end

  def allows_unique?
    false
  end

  def csv_value(item, current_user=nil)
    value = super

    if value.is_a?(Hash)
      process_single_file(value, item)
    elsif value.is_a?(Array)
      process_multiple_files(value, item)
    end
  end

  def sql_value(item)
    value = super

    files = []
    if value.is_a?(Hash) && value["path"].present?
      value["path"] = value["path"].gsub("upload/#{item.catalog.slug}", "files")
      files << { :path => value["path"].gsub("'") { "\'" } }
    elsif value.is_a?(Array) && value.present?
      value.map do |f|
        next if f["path"].blank?

        f["path"] = f["path"].gsub("upload/#{item.catalog.slug}", "files")
        files << { :path => f["path"].gsub("'") { "\'" } }
      end
    end

    files.to_json
  end

  def sql_type
    "JSON"
  end

  private

  def format_path_for_export(path, item)
    path.gsub!("upload/#{item.catalog.slug}", "files")
  end

  def process_single_file(value, item)
    return if value["path"].blank?

    format_path_for_export(value["path"], item)
  end

  def process_multiple_files(values, item)
    return if values.blank?

    values.map do |i|
      next if i["path"].blank?

      format_path_for_export(i["path"], item)
    end.join('; ')
  end
end
