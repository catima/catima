require "test_helper"

class JavascriptHelperTest < ActionView::TestCase
  include Sprockets::Rails::Helper
  include JavascriptHelper

  test "#javascript_include_async_tag doesn't do anything in debug mode" do
    Mocha::Configuration.allow(:stubbing_non_public_method) do
      stubs(:request_debug_assets?).returns(true)
    end
    js_tag = javascript_include_tag("http://example.com/foo.js")
    js_async_tag = javascript_include_async_tag("http://example.com/foo.js")
    assert_equal(js_tag, js_async_tag)
  end

  test "javascript_include_async_tag adds async attribute" do
    assert_equal(
      '<script src="http://example.com/foo.js" async="async"></script>',
      javascript_include_async_tag("http://example.com/foo.js"))
  end
end
