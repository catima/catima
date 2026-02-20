class ViatimagesPagesController < PagesController
  include AdvancedSearchConfig

  def show
    geosearch_slug = 'geosearch'

    if params[:slug] == geosearch_slug
      # A page with the "geosearch" slug should be available in the catalog. This page
      # should reference the "Image" item Type, and have a map container for each language.
      page = catalog.pages.find_by(slug: geosearch_slug)

      return super unless page

      @container = page.containers.find_by(page_id: page.id, locale: I18n.locale.to_s)

      geofeature_classes_item_type = catalog.item_types.find_by(slug: 'geo-feature-classes')
      geofeature_item_type = catalog.item_types.find_by(slug: 'geo-features')
      @geo_feature_primary_field = geofeature_item_type.field_for_select

      # Retrieve the geographic features and create objects with
      # the properties needed for the select elements.
      @features_select = [
        {
          name: 'sel_regions',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Region/Canton"),
          label: '.viat-geosearch-regions'
        },
        {
          name: 'sel_villes',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Place name/Locality"),
          label: '.viat-geosearch-cities'
        },
        {
          name: 'sel_vallees',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Valley"),
          label: '.viat-geosearch-valleys'
        },
        {
          name: 'sel_chaines_montagnes',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Mountain range"),
          label: '.viat-geosearch-mountain-ranges'
        },
        {
          name: 'sel_cols',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Pass"),
          label: '.viat-geosearch-passes'
        },
        {
          name: 'sel_montagnes',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Mountain"),
          label: '.viat-geosearch-mountains'
        },
        {
          name: 'sel_lacs',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Lake"),
          label: '.viat-geosearch-lakes'
        },
        {
          name: 'sel_cours_eau',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Watercourse, river"),
          label: '.viat-geosearch-rivers'
        },
        {
          name: 'sel_cascades',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Waterfall"),
          label: '.viat-geosearch-waterfalls'
        },
        {
          name: 'sel_glaciers',
          items: find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Glacier"),
          label: '.viat-geosearch-glaciers'
        }
      ]

      # Retrieve & sort the all the corpus
      corpus_type = catalog.item_types.find_by(slug: 'corpus')
      @corpuses = [] unless corpus_type
      @corpuses = corpus_type.items
                             .order(Arel.sql("data->>'#{corpus_type.find_field('titre').uuid}'"))

      # Retrieve the geographic images for a specific feature
      geographic_images = geographic_images(params[:feature]) if params[:feature].present?

      # Retrieve the geographic images for a specific corpus
      corpus_images = corpus_images(params[:corpus]) if params[:corpus].present?

      # Check if geographic_images or corpus_images are present and return the
      # value as @geojson. If both are present, always choose corpuses.
      @geojson = corpus_images || geographic_images

      # Set the base paths for the feature & corpus links
      @base_feature_path = "#{viatimages_pages_path(locale: I18n.locale, slug: geosearch_slug)}?feature="
      @base_corpus_path = "#{viatimages_pages_path(locale: I18n.locale, slug: geosearch_slug)}?corpus="
    end

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param

    super
  end

  private

  def find_geographic_items(geofeature_classes_item_type, geofeature_item_type, class_name)
    geofeature_class_item = geofeature_classes_item_type.items.find_by(
      "(data->>'#{geofeature_classes_item_type.find_field('nom').uuid}')::jsonb->'_translations'->>'en' = ?", class_name
    )

    return [] unless geofeature_class_item

    geofeature_item_type.items.where(
      "data->>'#{geofeature_item_type.find_field('geo-feature-class').uuid}' = ?", geofeature_class_item.id.to_s
    ).order(Arel.sql("(data->>'#{geofeature_item_type.find_field('nom').uuid}')::jsonb->'_translations'->>'#{I18n.locale}'"))
  end

  def geographic_images(item_id)
    images_item_type = catalog.item_types.find_by(slug: 'images')

    return [] unless images_item_type && item_id

    images_geo_field = images_item_type.find_field('geo-location')
    images_geo_features_field = images_item_type.find_field('geo')

    return [] unless images_geo_field && images_geo_features_field

    geo_images_ids = images_item_type.items.where(
      "(data->>'#{images_geo_features_field.uuid}')::jsonb @> ?", "[\"#{item_id}\"]"
    ).pluck(:id)

    return [] unless geo_images_ids.present?

    geojson(images_item_type, images_geo_field, geo_images_ids)
  end

  def corpus_images(item_id)
    images_item_type = catalog.item_types.find_by(slug: 'images')

    return [] unless images_item_type && item_id

    images_geo_field = images_item_type.find_field('geo-location')
    corpus_field = images_item_type.find_field('corpus')

    return [] unless images_geo_field

    corpus_images_ids = images_item_type.items.where(
      "(data->>'#{corpus_field.uuid}')::jsonb = ?", item_id
    ).pluck(:id)

    return [] unless corpus_images_ids.present?

    geojson(images_item_type, images_geo_field, corpus_images_ids)
  end

  def geojson(images_item_type, images_geo_field, images_ids)
    features = { "type" => "FeatureCollection", "features" => [] }

    sql = build_sql_query(images_item_type, images_geo_field, images_ids)

    res = ActiveRecord::Base.connection.execute(sql)

    data = JSON.parse(res[0]['geojson'])

    features['features'].concat(data['features']) if data['features'].present?

    features
  end

  def build_sql_query(images_item_type, images_geo_field, images_ids)
    <<-SQL.squish
      SELECT jsonb_build_object('features', CASE WHEN (array_agg(feat) IS NOT NULL) THEN array_to_json(array_agg(feat)) ELSE '[]' END) AS geojson
      FROM (
        SELECT jsonb_build_object('geometry', jsonb_array_elements(feats)->'geometry', 'properties', jsonb_build_object('id', id, 'polygon_color', '#{images_geo_field.polygon_color}', 'polyline_color', '#{images_geo_field.polyline_color}'), 'type', 'Feature') AS feat
        FROM (
          SELECT id, data->'#{images_geo_field.uuid}'->'features' AS feats
          FROM items
          WHERE item_type_id = #{images_item_type.id} AND data->'#{images_geo_field.uuid}'->'features' IS NOT NULL
          AND id IN (#{images_ids.join(',')})
        ) A
      ) B
    SQL
  end
end
