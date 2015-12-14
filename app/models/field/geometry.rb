# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_in_list          :boolean          default(TRUE), not null
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

  def custom_item_permitted_attributes
    [:"#{uuid}_json"]
  end

  def value_as_json_string(item)
    existing_input = item.instance_variable_get("@#{uuid}_json_string")
    return existing_input unless existing_input.nil?

    hash = raw_value(item)
    hash && JSON.pretty_generate(hash)
  end

  def assign_value_from_json_string(item, json)
    item.instance_variable_set("@#{uuid}_json_string", json)
    item.public_send("#{uuid}=", JSON.parse(json))
  rescue JSON::ParserError
    # ignore
  end

  # The actual geometry data is stored as a Hash, but to facilitate user input,
  # we need to create a virtual attribute that is a string. This virtual
  # attribute gets the name "#{uuid}_json".
  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_json") do
      field.value_as_json_string(self)
    end
    klass.send(:define_method, "#{uuid}_json=") do |json|
      field.assign_value_from_json_string(self, json)
    end
  end

  private

  def build_validators
    [JsonValidator]
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
