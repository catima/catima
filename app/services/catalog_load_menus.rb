class CatalogLoadMenus
  def initialize(path, slug)
    @path = path
    @slug = slug
  end

  def load
    @catalog = Catalog.find_by(slug: @slug)
    return unless File.exist?(@path)

    File.open(@path) do |f|
      JSON.parse(f.read)['menu-items'].each { |m| load_menu_item(m) }
    end
  end

  def load_menu_item(m)
    menu_item = @catalog.menu_items.new
    menu_item.update_from_json(m)
  end
end
