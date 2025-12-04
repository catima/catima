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

class Field::Geometry < Field
  ZOOM_LEVEL = {
    "distant" => (ENV['ZOOM_LEVEL_DISTANT'].presence || 5).to_i,
    "medium" => (ENV['ZOOM_LEVEL_MEDIUM'].presence || 10).to_i,
    "close" => (ENV['ZOOM_LEVEL_CLOSE'].presence || 15).to_i
  }.freeze
  POLYGON_COLOR = ENV.fetch('POLYGON_COLOR', "#9336af").freeze
  POLYLINE_COLOR = ENV.fetch('POLYLINE_COLOR', "#000000").freeze

  store_accessor :options, :bounds, :layers, :zoom, :polygon, :polyline

  validates_numericality_of :zoom,
                            :only_integer => true,
                            :greater_than_or_equal_to => Field::Geometry::ZOOM_LEVEL['distant'],
                            :less_than_or_equal_to => Field::Geometry::ZOOM_LEVEL['close'],
                            :allow_blank => false

  validates_format_of :polygon, :polyline,
                      :with => /\A#(?:[A-F0-9]{3}){1,2}\z/i,
                      :allow_blank => false

  def human_readable?
    false
  end

  def allows_unique?
    false
  end

  def edit_props(_item)
    {
      "bounds" => default_bounds,
      "layers" => geo_layers,
      "zoom" => zoom_level.to_i,
      "polygonColor" => polygon_color,
      "polylineColor" => polyline_color,
      "required" => required?
    }
  end

  def custom_field_permitted_attributes
    %i(bounds layers zoom polygon polyline)
  end

  def default_bounds(xmin: -60, xmax: 60, ymin: -45, ymax: 65)
    geo_bounds = bounds.present? ? JSON.parse(bounds) : { 'xmin' => xmin, 'xmax' => xmax, 'ymin' => ymin, 'ymax' => ymax }
    geo_bounds.slice('xmin', 'xmax', 'ymin', 'ymax')
  end

  def geo_layers
    layers.present? ? JSON.parse(layers) : []
  end

  def zoom_level
    zoom.presence || Field::Geometry::ZOOM_LEVEL['medium']
  end

  def polygon_color
    polygon.presence || Field::Geometry::POLYGON_COLOR
  end

  def polyline_color
    polyline.presence || Field::Geometry::POLYLINE_COLOR
  end

  def csv_value(_item, _user=nil)
    return if super.blank?

    super["features"].map do |f|
      next unless f['geometry']&.key?('coordinates')

      case f['geometry']['type']
      when 'Point'
        "[#{f['geometry']['coordinates'][1]},#{f['geometry']['coordinates'][0]}]"
      when 'Polygon'
        f['geometry']['coordinates'][0].map do |coord|
          "[#{coord[1]},#{coord[0]}]"
        end.join(", ")
      else # LineString & everything else
        f['geometry']['coordinates'].map do |coord|
          "[#{coord[1]},#{coord[0]}]"
        end.join(", ")
      end
    end.join("; ")
  end

  def sql_value(_item)
    super&.dig("features")&.to_json || "[]"
  end

  def sql_type
    "JSON"
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
      result = ::Field::Geometry.connection.select_value(<<-SQL.squish)
        SELECT validate_geojson(#{value_sql})
      SQL
      result == "t"
    end
  end
end
