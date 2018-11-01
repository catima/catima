module DocumentationHelper
  def markdown_2_html(file_name)
    markdown = Redcarpet::Markdown.new(
      DocRender.new(
        :locale => define_locale(file_name),
        :with_toc_data => true
      ),
      autolink: true,
      tables: true,
      filter_html: true,
      hard_wrap: true,
      prettify: true
    )
    markdown.render(raw_content(file_name))
  end

  def random_id
    range = [*'A'..'Z', *'a'..'z']
    Array.new(10) { range.sample }.join
  end

  private

  def raw_content(file_name)
    Net::HTTP.get(
      URI.parse(content_url(file_name, define_locale(file_name)))
    ).force_encoding("UTF-8")
  end

  def content_url(file_name, locale=I18n.locale)
    ENV['DOC_BASE_URL'] + "/" + locale.to_s + "/" + file_name
  end

  # Define current locale for the content url if the
  # markdown file is available, fallback to French otherwise
  def define_locale(file_name)
    return I18n.locale.to_s if file_available?(file_name)

    "fr"
  end

  def file_available?(file_name)
    Net::HTTP.get(
      URI.parse(content_url(file_name))
    ).is_a?(Net::HTTPSuccess)
  end
end
