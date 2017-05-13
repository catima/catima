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
#  editor_component         :string
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
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

class Field::Geometry < ::Field
  # TODO: CRS?

  def human_readable?
    false
  end

  private

  def build_validators
    [] # [JsonValidator]
  end

  class JsonValidator < ActiveModel::Validator
    def validate(record)
      attrib = Array.wrap(options[:attributes]).first
      attrib = "#{attrib}_json" unless attrib == :default_value
      value = record.public_send(attrib)

      return if value.blank?
      return if postgis_valid_json?(value)

      record.errors.add(
        attrib,
        "does not appear to a valid geometry in GeoJSON format"
      )
    end

    private

    def postgis_valid_json?(value)
      value_sql = ::Field::Geometry.send(:sanitize_sql, ["'%s'", value])
      result = ::Field::Geometry.connection.select_value(<<-SQL)
        SELECT validate_geojson(#{value_sql})
      SQL
      result == "t"
    end
  end
end
