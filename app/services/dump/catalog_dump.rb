class Dump::CatalogDump < ::Dump
  def initialize
  end

  def dump(catalog, directory)
    cat = Catalog.find_by(slug: catalog)
    raise "ERROR. Catalog '#{catalog}' not found." if cat.nil?

    # Check if directory exists; create if necessary,
    # if not empty raise an error.
    create_output_dir directory

    # Write meta.json file. Contains information about
    # the dump, format version etc.
    write_meta directory

    # Export structure
    Rails.logger.info "Dumping structure for catalog #{cat.id}..."
    dump_structure(cat, directory)

    # Export data & files
    Rails.logger.info "Dumping data & files for catalog #{cat.id}..."
    dump_data(cat, directory)
    dump_files(cat, directory)

    # Dump pages
    Rails.logger.info "Dumping pages for catalog #{cat.id}..."
    dump_pages(cat, directory)
    dump_menu_items(cat, directory)
  end

  def dump_structure(cat, dir)
    struct_dir = File.join(dir, 'structure')
    Dir.mkdir struct_dir

    # Dump the catalog information
    Rails.logger.info "Dumping catalog information for catalog #{cat.id}..."
    dump_catalog_information(cat, struct_dir)

    # Dump all the item types
    Rails.logger.info "Dumping item types for catalog #{cat.id}..."
    dump_item_types_structure(cat, struct_dir)

    # Dump categories
    Rails.logger.info "Dumping categories for catalog #{cat.id}..."
    dump_categories(cat, struct_dir)

    # Dump choice sets
    Rails.logger.info "Dumping choice sets for catalog #{cat.id}..."
    dump_choice_sets(cat, struct_dir)
  end

  def dump_catalog_information(cat, struct_dir)
    cat_json = cat.as_json(only: [:slug, :name, :primary_language, :other_languages,
                                  :advertize, :requires_review]
                          )
    File.write(File.join(struct_dir, 'catalog.json'), JSON.pretty_generate(cat_json))
  end

  def dump_item_types_structure(cat, struct_dir)
    item_type_dir = File.join(struct_dir, 'item-types')
    Dir.mkdir item_type_dir
    cat.item_types.each do |it|
      dump_item_type_structure(it, item_type_dir)
    end
  end

  def dump_item_type_structure(item, dir)
    dmp = item.as_json(only: %i(slug name_translations name_plural_translations))
    dmp["fields"] = item.fields.map(&:describe)
    dmp['item-views'] = item.item_views.map(&:describe)
    File.write(File.join(dir, "#{item.slug}.json"), JSON.pretty_generate(dmp))
  end

  def dump_categories(cat, struct_dir)
    File.write(
      File.join(struct_dir, 'categories.json'),
      JSON.pretty_generate("categories": cat.categories.map(&:describe))
    )
  end

  def dump_choice_sets(cat, struct_dir)
    File.write(
      File.join(struct_dir, 'choice-sets.json'),
      JSON.pretty_generate("choice-sets": cat.choice_sets.map(&:describe))
    )
  end

  def dump_data(cat, dir)
    data_dir = File.join(dir, 'data')
    Dir.mkdir data_dir
    cat.item_types.each { |it| dump_items(it, data_dir) }
  end

  def dump_items(item_type, dir)
    File.write(
      File.join(dir, "#{item_type.slug}.json"),
      JSON.pretty_generate("item-type": item_type.slug, "items": item_type.items.map(&:describe))
    )
  end

  def dump_pages(cat, dir)
    pages_dir = File.join(dir, 'pages')
    Dir.mkdir pages_dir
    cat.pages.each { |p| dump_page(p, pages_dir) }
  end

  def dump_page(page, dir)
    File.write(File.join(dir, "#{page.slug}.json"), JSON.pretty_generate(page.describe))
  end

  def dump_menu_items(cat, dir)
    File.write(
      File.join(dir, "menus.json"),
      JSON.pretty_generate("menu-items": cat.menu_items.map(&:describe))
    )
  end
end
