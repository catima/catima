class CatalogLoadData
  def initialize(dir, slug)
    @data_dir = dir
    @slug = slug
  end

  def load
    catalog = Catalog.find_by(slug: @slug)
    return unless File.directory?(@data_dir)
    # In a first round we load the base data for each item type.
    load_item_types(catalog)
    # In a second roud we also build the values for all reference fields.
    build_references(catalog)
    # We also need to fix the paths for the image fields (thumbnails slug)
    catalog.item_types.each { |it| update_slug_for_file_fields(it) }
  end

  def load_item_types(catalog)
    Dir[File.join(@data_dir, '*.json')].each do |data_file|
      File.open(data_file) do |f|
        data_json = JSON.parse(f.read)
        load_items(catalog, data_json)
      end
    end
  end

  def load_items(catalog, items_json)
    # Get the correct item type first.
    it = catalog.item_types.where(slug: items_json['item-type']).first!
    # Build the item
    items_json['items'].each { |item| build_item(it, item) }
  end

  def build_item(item_type, item_json)
    item = item_type.items.new.tap do |i|
      i.catalog = item_type.catalog
      i.uuid = item_json['uuid']
      i.creator_id = 1
    end.behaving_as_type
    item.update(Hash[item_json.except('uuid').collect { |k, v| [item_type.fields.where(slug: k).first!.uuid, v] }])
  end

  # Builds the references between items based on the UUIDs stored instead.
  def build_references(catalog)
    catalog.item_types.each { |it| build_references_for_item_type(it) }
  end

  def build_references_for_item_type(it)
    it.fields.each do |fld|
      if fld.type == 'Field::Reference'
        build_references_for_field(it, fld)
      elsif fld.type == 'Field::ChoiceSet'
        build_choiceset_for_field(it, fld)
      end
    end
  end

  def build_references_for_field(it, fld)
    related_it = ItemType.find(fld.related_item_type_id)
    # TODO: check if value is always an array or if it can also be a string or null
    it.items.each do |i|
      i.set_by_uuid(fld.uuid, related_items_ids_from_uuids(i, fld, related_it))
    end
  end

  def related_items_ids_from_uuids(i, fld, related_it)
    i.data[fld.uuid].collect { |v| related_it.items.where(uuid: v).first.id.to_s }
  end

  def build_choiceset_for_field(it, fld)
    related_cs = ChoiceSet.find(fld.choice_set_id)
    # TODO: check if value is always an array or if it can also be a string or null
    it.items.each do |i|
      i.set_by_uuid(fld.uuid, related_choices_ids_from_uuids(i, fld, related_cs))
    end
  end

  def related_choices_ids_from_uuids(i, fld, related_cs)
    i.data[fld.uuid].collect { |v| related_cs.choices.where(uuid: v).first.id.to_s }
  end

  def update_slug_for_file_fields(it)
    it.fields.each { |fld| update_slug_for_file_field(it, fld) }
  end

  def update_slug_for_file_field(it, fld)
    return unless fld.type == 'Field::Image' || fld.type == 'Field::File'
    it.items.each { |i| update_slug_for_item_and_field(i, fld) }
  end

  def update_slug_for_item_and_field(i, fld)
    return if i.data[fld.uuid].nil?
    i.behaving_as_type.update(fld.uuid => convert_file_path(i.data[fld.uuid], i.catalog.slug))
  end

  def convert_file_path(path, new_slug)
    path_elems = path['path'].split('/')
    path_elems[1] = new_slug
    path['path'] = path_elems.join('/')
    path
  end
end
