class Container::Map < ::Container
  store_accessor :content, :item_type, :base_layers

  def custom_container_permitted_attributes
    %i(item_type geom_field base_layers)
  end

  def geojson
    @item_type = catalog.item_types.where(:id => item_type).first!
    @geom_field = @item_type.fields.where(:type => 'Field::Geometry').first!

    # Execute the SQL query for retrieving all geometries of all items of this type
    # as a GeoJSON.
    sql = "SELECT jsonb_build_object('features', array_to_json(array_agg(feat)), 'type', 'FeatureCollection') AS geojson FROM "\
          "(SELECT jsonb_build_object('geometry', jsonb_array_elements(feats)->'geometry', 'properties', jsonb_build_object('id', id), 'type', 'Feature') AS feat "\
          "FROM "\
          "(SELECT id, data->'#{@geom_field.uuid}'->'features' AS feats FROM items "\
          "WHERE item_type_id = #{@item_type.id} "\
          "AND data->'#{@geom_field.uuid}'->'features' IS NOT NULL) A) B"
    res = ActiveRecord::Base.connection.execute(sql)
    res[0]['geojson']
  end

  def describe
    super.merge('content' => { 'item_type' => item_type.nil? ? nil : ItemType.find(item_type).slug })
  end

  def update_from_json(d)
    unless d[:content].nil?
      it = catalog.item_types.find_by(slug: d[:content]['item_type'])
      d[:content]['item_type'] = it.id.to_s
    end
    super(d)
  end
end
