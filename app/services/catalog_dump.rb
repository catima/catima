require 'fileutils'

class CatalogDump
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
    dump_structure(cat, directory)

    # Export data & files
    dump_data(cat, directory)
    dump_files(cat, directory)

    # Dump pages and menu items
    dump_pages(cat, directory)
    dump_menu_items(cat, directory)
  end

  def write_meta(dir)
    meta = { dump_created_at: Time.now.utc.to_s, dump_version: '1.0' }
    File.write(File.join(dir, 'meta.json'), JSON.pretty_generate(meta))
  end

  def create_output_dir(d)
    if File.exist?(d) && !File.directory?(d)
      raise "ERROR. '#{d}' is a file. Please specify an non-existing or empty directory."
    end
    if File.directory?(d) && !Dir[File.join(d, '*')].empty?
      raise "ERROR. '#{d}' is not empty. Please specify an non-existing or empty directory."
    end
    FileUtils.mkdir_p(d) unless File.exist?(d)
  end

  def dump_structure(cat, dir)
    struct_dir = File.join(dir, 'structure')
    Dir.mkdir struct_dir

    # Dump the catalog information
    dump_catalog_information(cat, struct_dir)

    # Dump all the item types
    dump_item_types_structure(cat, struct_dir)

    # Dump categories
    dump_categories(cat, struct_dir)

    # Dump choice sets
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

  def dump_item_type_structure(it, dir)
    dmp = it.as_json(only: %i(slug name_translations name_plural_translations))
    dmp["fields"] = it.fields.map(&:describe)
    File.write(File.join(dir, "#{it.slug}.json"), JSON.pretty_generate(dmp))
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

  def dump_files(cat, dir)
    files_dir = File.join(dir, 'files')
    Dir.mkdir files_dir
    FileUtils.cp_r(
      Dir.glob(File.join(Rails.public_path, 'upload', cat.slug, '*')),
      files_dir
    )
  end

  def dump_pages(cat, dir)
    pages_dir = File.join(dir, 'pages')
    Dir.mkdir pages_dir
    cat.pages.each { |p| dump_page(p, pages_dir) }
  end

  def dump_page(p, dir)
    File.write(File.join(dir, "#{p.slug}.json"), JSON.pretty_generate(p.describe))
  end

  def dump_menu_items(cat, dir)
    File.write(
      File.join(dir, "menus.json"),
      JSON.pretty_generate("menu-items": cat.menu_items.map(&:describe))
    )
  end
end
