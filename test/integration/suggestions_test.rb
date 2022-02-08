require "test_helper"

class SuggestionsTest < ActionDispatch::IntegrationTest
  test "make suggestion on item page as user" do
    log_in_as("one-user@example.com", "password")
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")

    find("#toggle-suggestion-button").click
    fill_in("suggestion[content]", :with => "This is a test suggestion")
    click_on("Send suggestion")

    assert(page.has_content?("Your suggestion has been sent"))
  end

  test "cannot view suggestion form on item page as guest" do
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")

    refute(page.has_selector?('#toggle-suggestion-button'))
    refute(page.has_selector?('textarea#suggestion_content'))
    refute(page.has_selector?('#send-suggestion-button'))
  end
end
