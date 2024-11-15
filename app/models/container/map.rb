# == Schema Information
#
# Table name: containers
#
#  content    :jsonb
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  locale     :string
#  page_id    :integer
#  row_order  :integer
#  slug       :string
#  type       :string
#  updated_at :datetime         not null
#

class Container::Map < Container
  DEFAULT_MAP_HEIGHT = 400

  store_accessor :content, :item_type, :layers, :height, :geofields

  validate :item_type_validation, :geofields_validation

  def custom_container_permitted_attributes
    %i(item_type layers height geofields)
  end

  def geojson
    @item_type = catalog.item_types.find_by(id: item_type)
    return unless @item_type

    features = { "type" => "FeatureCollection", "features" => [] }

    fields = geo_fields_as_fields

    # Get all geo fields if none are selected.
    fields = @item_type.fields.where(type: 'Field::Geometry') if fields.empty?

    fields.each do |field|
      res = find_geometries_query(field)
      data = JSON.parse(res[0]['geojson'])

      features['features'].concat(data['features']) if data['features'].present?
    end

    features
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "#{e.class}: #{e.message}"
  end

  def describe
    super.merge('content' => { 'item_type' => item_type.nil? ? nil : ItemType.find(item_type).slug })
  end

  def map_height
    height.present? ? height.to_i : DEFAULT_MAP_HEIGHT
  end

  def geo_layers
    layers.present? ? JSON.parse(layers) : []
  end

  def geo_fields
    geofields.present? ? JSON.parse(geofields) : []
  end

  def geo_fields_as_fields
    @item_type = catalog.item_types.find_by(id: item_type)

    if @item_type.present?
      return @item_type
             .fields
             .where(:type => 'Field::Geometry')
             .filter { |f| geo_fields.include?(f.id) }
    end

    []
  end

  def update_from_json(data)
    unless data[:content].nil?
      it = catalog.item_types.find_by(slug: data[:content]['item_type'])
      data[:content]['item_type'] = it.id.to_s
    end
    super
  end

  private

  def item_type_validation
    return if item_type.present?

    errors.add :item_type, I18n.t('catalog_admin.containers.item_type_warning')
  end

  def geofields_validation
    return if geo_fields.empty?

    @item_type = catalog.item_types.find_by(id: item_type)
    if @item_type.present?
      valid_geofield_ids = @item_type
                           .fields
                           .where(:type => 'Field::Geometry')
                           .pluck(:id)
    end

    invalid_fields = geo_fields - (valid_geofield_ids || [])

    return unless invalid_fields.any?

    errors.add :geofields, I18n.t('catalog_admin.containers.geofields_invalid')
  end

  def find_geometries_query(field)
    sql =
      <<-SQL.squish
        SELECT jsonb_build_object('features', CASE WHEN (array_agg(feat) IS NOT NULL) THEN array_to_json(array_agg(feat)) ELSE '[]' END) AS geojson
        FROM (
          SELECT jsonb_build_object('geometry', jsonb_array_elements(feats)->'geometry', 'properties', jsonb_build_object('id', id, 'polygon_color', '#{field.polygon_color}', 'polyline_color', '#{field.polyline_color}'), 'type', 'Feature') AS feat
          FROM (
            SELECT id, data->'#{field.uuid}'->'features' AS feats
            FROM items
            WHERE item_type_id = #{@item_type.id} AND data->'#{field.uuid}'->'features' IS NOT NULL
          ) A
        ) B
      SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
