require 'fileutils'

class CatalogLoad
  def initialize(dir, slug)
    @load_dir = dir
    @slug = slug
  end

  def load
    check_load_dir
    File.open(File.join(@load_dir, 'structure', 'catalog.json')) do |f|
      create_catalog(JSON.parse(f.read))
    end
    load_structure
    load_data
    # load_pages
    copy_files
  end

  private

  def check_load_dir
    raise "ERROR. '#{@load_dir}' is not a directory." unless File.directory?(@load_dir)
    m = meta
    raise "ERROR. Dump version '#{meta['dump_version']}' is not supported." unless m['dump_version'] == '1.0'
  end

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
    CatalogLoadStructure.new(File.join(@load_dir, 'structure'), @slug).load
  end

  def load_data
    CatalogLoadData.new(File.join(@load_dir, 'data'), @slug).load
  end

  def copy_files
    dest_dir = File.join(Rails.public_path, 'upload', @slug)
    FileUtils.mkdir_p dest_dir
    FileUtils.cp_r(
      Dir.glob(File.join(@load_dir, 'files', '*')),
      dest_dir
    )
  end
end
