class CatalogLoad
  def initialize(dir, slug)
    @load_dir = dir
    @slug = slug
  end

  def load
    raise "ERROR. '#{@load_dir}' is not a directory." unless File.directory?(@load_dir)
    m = meta
    raise "ERROR. Dump version '#{meta['dump_version']}' is not supported." unless m['dump_version'] == '1.0'
    File.open(File.join(@load_dir, 'structure', 'catalog.json')) do |f|
      create_catalog(JSON.parse(f.read))
    end
    load_structure
  end

  private

  # Gets the meta information
  def meta
    File.open(File.join(@load_dir, 'meta.json')) do |f|
      JSON.parse(f.read)
    end
  end

  # Creates a new empty catalog
  def create_catalog(catalog_info)
    @slug ||= catalog_info['slug']
    # Check if such a catalog already exists
    catalog = Catalog.find_by(slug: @slug)
    raise "ERROR. Catalog '#{@slug}' already exists. Please specify a unique catalog slug." unless catalog.nil?
    Catalog.new(catalog_info.merge(slug: @slug)).save
  end

  def load_structure
    catalog = Catalog.find_by(slug: @slug)

    # Load first the categories (they don't have any dependency)
    load_categories(catalog, File.join(@load_dir, 'structure', 'categories.json'))

    # Load the choice sets
    load_choice_sets(catalog, File.join(@load_dir, 'structure', 'choice-sets.json'))

    # Load the item types
  end

  def load_categories(catalog, categories_file)
    return unless File.exist?(categories_file)
    File.open(categories_file) do |f|
      JSON.parse(f.read)['categories'].each { |cat| load_category(catalog, cat) }
    end
  end

  def load_category(catalog, category_info)
    category = catalog.categories.build(category_info.slice("name", "uuid").merge(
                                          created_at: DateTime.current, updated_at: DateTime.current))
    category.save
    category_info['fields'].each { |fld_info| category.fields.build(fld_info).save }
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
end
