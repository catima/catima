class CatalogLoadStructure
  def initialize(dir, slug)
    @struct_dir = dir
    @slug = slug
  end

  def load
    catalog = Catalog.find_by(slug: @slug)
    load_categories(catalog, File.join(@struct_dir, 'categories.json'))
    load_choice_sets(catalog, File.join(@struct_dir, 'choice-sets.json'))
    load_item_types(catalog, File.join(@struct_dir, 'item-types'))
    load_category_fields
  end

  private

  def load_categories(catalog, categories_file)
    return unless File.exist?(categories_file)
    @categories = []
    File.open(categories_file) do |f|
      JSON.parse(f.read)['categories'].each do |cat_info|
        cat = load_category(catalog, cat_info)
        @categories.append([cat, cat_info])
      end
    end
  end

  def load_category(catalog, category_info)
    category = catalog.categories.build(category_info.slice("name", "uuid").merge(
                                          created_at: DateTime.current, updated_at: DateTime.current))
    category.save
    category
  end

  def load_category_fields
    @categories.each do |arr|
      category = arr[0]
      category_info = arr[1]
      category_info['fields'].each { |fld_info| build_field(category, fld_info) }
    end
  end

  def load_choice_sets(catalog, choice_sets_file)
    return unless File.exist?(choice_sets_file)
    File.open(choice_sets_file) do |f|
      JSON.parse(f.read)['choice-sets'].each { |cs| load_choice_set(catalog, cs) }
    end
  end

  def load_choice_set(catalog, cs_info)
    choice_set = catalog.choice_sets.build(cs_info.slice("name", "uuid"))
    choice_set.save
    cs_info['choices'].each { |choice| build_choice(choice_set, choice) }
  end

  def build_choice(cs, ch_info)
    cat = cs.catalog.categories.where(uuid: ch_info['category']).first
    cs.choices.build(ch_info.merge('category': cat)).save
  end

  def load_item_types(catalog, item_types_directory)
    return unless File.directory?(item_types_directory)
    # First we create the empty item types, without fields
    # Fields can potentially reference other item types, so they have to
    # exist at the moment the field is created.
    items = []
    Dir[File.join(item_types_directory, '*.json')].each do |it_file|
      File.open(it_file) do |f|
        it_json = JSON.parse(f.read)
        it = load_item_type(catalog, it_json)
        items.append([it, it_json])
      end
    end

    # And now we can build the fields
    items.each { |arr| load_item_type_fields(arr[0], arr[1]) }

    # Load the item views
    items.each { |arr| load_item_views(arr[0], arr[1]) }
  end

  def load_item_type(catalog, it_info)
    it = catalog.item_types.build(it_info.except("fields", 'item-views'))
    it.save
    it
  end

  def load_item_type_fields(it, it_info)
    it_info['fields'].each { |fld_info| build_field(it, fld_info) }
  end

  def load_item_views(it, it_info)
    # TODO : catalog_load_structure.rb:load_item_views
  end

  def build_field(field_set, fld_info)
    cs = choice_set_id(field_set.catalog, fld_info['choice_set'])
    it = item_type_id(field_set.catalog, fld_info['related_item_type'])
    fld_def = fld_info.except('choice_set', 'related_item_type').merge('choice_set_id': cs, 'related_item_type_id': it)
    field_set.fields.build(fld_def).save
  end

  def choice_set_id(catalog, uuid)
    cs = catalog.choice_sets.where(uuid: uuid).first
    cs && cs.id
  end

  def item_type_id(catalog, uuid)
    it = catalog.item_types.where(slug: uuid).first
    it && it.id
  end
end
