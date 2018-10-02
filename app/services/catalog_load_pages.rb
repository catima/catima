class CatalogLoadPages
  def initialize(dir, slug)
    @dir = dir
    @slug = slug
  end

  def load
    @catalog = Catalog.find_by(slug: @slug)
    return unless File.directory?(@dir)

    load_pages
  end

  def load_pages
    Dir[File.join(@dir, '*.json')].each do |page_file|
      File.open(page_file) { |f| load_page(JSON.parse(f.read)) }
    end
  end

  def load_page(page_json)
    p = @catalog.pages.new do |model|
      model.creator_id = 1
    end
    p.update(page_json.except('containers'))
    load_containers(p, page_json['containers'])
  end

  def load_containers(page, containers_json)
    containers_json.each { |c| load_container(page, c) }
  end

  def load_container(page, container_json)
    container_class = container_json['type'].constantize
    c = container_class.new(container_json.except('type', 'content').merge('page' => page))
    c.update_from_json('content': container_json['content'])
  end
end
