require 'fileutils'

class CatalogDump
  def initialize
  end


  def dump(catalog, directory)
    puts "Dumping catalog to '#{directory}..."

    # Check if directory exists; create if necessary,
    # if not empty raise an error.
    create_output_dir directory

    # Write meta.json file. Contains information about
    # the dump, format version etc.
    write_meta directory

    # Export structure
    dump_structure(catalog, directory)

    # TODO: Export data

    # TODO: Dump pages and menu items

    puts "\n\rDone!"
  end


  def write_meta dir
    meta = { dump_created_at: Time.now.to_s, dump_version: '1.0' }
    File.write(File.join(dir, 'meta.json'), JSON.pretty_generate(meta))
  end

  def create_output_dir(d)
    if File.exists?(d) and not File.directory?(d)
      raise "ERROR. '#{d}' is a file. Please specify an non-existing or empty directory."
    end
    if File.directory?(d) and not Dir[File.join(d, '*')].empty?
      raise "ERROR. '#{d}' is not empty. Please specify an non-existing or empty directory."
    end
    FileUtils::mkdir_p(d) unless File.exists?(d)
  end


  def dump_structure(catalog, dir)
    cat = Catalog.find_by({ slug:catalog })
    raise "ERROR. Catalog '#{catalog}' not found." if cat.nil?

    puts " |-- Dumping structure..."
    struct_dir = File.join(dir, 'structure')
    Dir.mkdir struct_dir

    # Dump the catalog information
    cat_json = cat.as_json(only: [
      :slug, :name, :primary_language, :other_languages, 
      :advertize, :requires_review
    ])
    File.write(File.join(struct_dir, 'catalog.json'), JSON.pretty_generate(cat_json))

    # Dump all the item types
    item_type_dir = File.join(struct_dir, 'item-types')
    Dir.mkdir item_type_dir
    cat.item_types.each do |it|
      dump_item_type_structure(it, item_type_dir)
    end

    # TODO: Dump categories
    # TODO: Dump choice sets
  end


  def dump_item_type_structure(it, dir)
    dmp = it.as_json(only: %i(slug name_translations name_plural_translations))
    dmp["fields"] = it.fields.map { |f| f.describe }
    File.write(File.join(dir,  "#{it.slug}.json"), JSON.pretty_generate(dmp))
  end
end
