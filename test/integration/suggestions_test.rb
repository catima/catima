require "test_helper"

class SuggestionsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "view suggestion form on item page as user" do
    log_in_as("one-user@example.com", "password")
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")

    assert(page.assert_selector('i.fa-comment'))
    assert(page.assert_selector('textarea#suggestion_content'))
    assert(page.assert_selector('input', value: "Send suggestion"))
  end

  test "view suggestion form on item page as guest" do
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")

    refute(page.assert_selector('i.fa-comment'))
    refute(page.assert_selector('textarea#suggestion_content'))
    refute(page.assert_selector('input', value: "Send suggestion"))
  end
end
