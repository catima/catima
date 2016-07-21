class Container::Markdown < ::Container
  store_accessor :content, :markdown

  def custom_container_permitted_attributes
    %i(markdown)
  end

  def render
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML, 
      { autolink: true, tables: true }
    )
    markdown.render(content['markdown'])
  end
end