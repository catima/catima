# Custom render class for the Redcarpet library
class CustomRender < Redcarpet::Render::HTML
  def initialize(options={})
    @options = options
    super(options)
  end

  # Image override to prepend a specific url
  def image(link, title, alt_text)
    %Q(<img src="#{ENV['DOC_BASE_URL']}/#{@options[:locale]}/#{link}" title="#{title}" alt="#{alt_text}">)
  end
end
