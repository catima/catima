# rubocop:disable Rails/Output
class CatalogLoadData
  def initialize(dir, slug)
    @data_dir = dir
    @slug = slug
  end

  def msg(txt)
    puts txt unless Rails.env.test?
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
        msg "   Loading data from #{data_file}..."
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
      i.review_status = item_json['review_status'] if item_json.key?('review_status')
      i.creator_id = 1
    end.behaving_as_type
    begin
      item_type_fields = item_type.fields.map(&:slug)
      item.update(Hash[item_json.except('uuid', 'review_status').collect { |k, v| [item_type.fields.where(slug: k).first!.uuid, v] }])
    rescue ActiveRecord::RecordNotFound
      msg "Error. Not all fields can be found for item type '#{item_type.slug}'. Expected fields: #{item_type_fields.join(', ')}. Found fields: #{item_json.keys.join(', ')}."
    end
  end

  # Builds the references between items based on the UUIDs stored instead.
  def build_references(catalog)
    msg "   Building references..."
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
    it.items.each do |i|
      i.set_by_uuid(fld.uuid, related_items_ids_from_uuids(i, fld, related_it))
    end
  end

  def related_items_ids_from_uuids(i, fld, related_it)
    d = i.data[fld.uuid]
    if d.is_a? Array
      i.data[fld.uuid].collect do |v|
        it = related_it.items.where(uuid: v).first
        it.nil? ? nil : it.id.to_s
      end
    else
      it = related_it.items.where(uuid: d).first
      it.nil? ? nil : it.id.to_s
    end
  end

  def build_choiceset_for_field(it, fld)
    related_cs = ChoiceSet.find(fld.choice_set_id)
    it.items.each do |i|
      i.set_by_uuid(fld.uuid, related_choices_ids_from_uuids(i, fld, related_cs))
    end
  end

  def related_choices_ids_from_uuids(i, fld, related_cs)
    d = i.data[fld.uuid]
    if d.is_a? Array
      d.collect do |v|
        cs = related_cs.choices.where(uuid: v).first
        cs.nil? ? nil : cs.id.to_s
      end
    else
      cs = related_cs.choices.where(uuid: d).first
      cs.nil? ? nil : cs.id.to_s
    end
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
    paths = path.class == Array ? path : [path]
    paths = paths.map do |p|
      path_elems = p['path'].split('/')
      path_elems[1] = new_slug
      p['path'] = path_elems.join('/')
      p
    end
    path.class == Array ? paths : paths[0]
  end
end
