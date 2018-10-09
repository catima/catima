module DocumentationHelper
  def markdown_2_html(url)
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: true,
      tables: true,
      filter_html: true,
      hard_wrap: true,
      prettify: true
    )
    markdown.render(retrieve_raw_content(url))
  end

  def random_id
    range = [*'A'..'Z', *'a'..'z']
    Array.new(10) { range.sample }.join
  end

  private

  def retrieve_raw_content(url)
    Net::HTTP.get(URI.parse(url)).force_encoding("UTF-8")
  end
end
