# Custom render class for the Redcarpet library
class DocRender < Redcarpet::Render::HTML
  def initialize(options={})
    @options = options
    super(options)
  end

  # Image override to prepend a specific url.
  def image(link, title, alt_text)
    %Q(<img src="#{ENV.fetch('DOC_BASE_URL')}/#{@options[:locale]}/#{link}" title="#{title}" alt="#{alt_text}">)
  end

  # Link override to prepend a specific url if the link
  # is relative and do not contains an anchor tag.
  # Otherwise the link is left untouched.
  def link(link, _, content)
    if relative_link?(link) && !link_contains_anchor?(link)
      %Q(<a href="#{ENV.fetch('DOC_BASE_URL')}/#{@options[:locale]}/#{link}" target="_blank">#{content}</a>)
    else
      %Q(<a href="#{link}">#{content}</a>)
    end
  end

  private

  # Check if a given link is relative.
  def relative_link?(link)
    uri = URI.parse(link)
    uri.relative?
  rescue URI::InvalidURIError
    false
  end

  # Check if a given link contains an anchor.
  def link_contains_anchor?(link)
    uri = URI.parse(link)
    uri.fragment.present?
  rescue URI::InvalidURIError
    false
  end
end
