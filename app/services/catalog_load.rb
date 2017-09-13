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
    # load_data
    # load_pages
  end

  private

  def load_structure
    CatalogLoadStructure.new(File.join(@load_dir, 'structure'), @slug).load
  end
end
