require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  should validate_presence_of(:page_id)
  should validate_presence_of(:content)
  should validate_presence_of(:locale)

  test "HTML containers reject content larger than 4 MiB" do
    container = Container::HTML.new(
      page: pages(:one),
      locale: "en",
      slug: "large-html",
      html: "a" * (Container::HTML::MAX_HTML_BYTES + 1)
    )

    assert_not container.valid?
    assert_includes container.errors[:html], "The HTML content is too large, please reduce it"
  end
end
