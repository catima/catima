require "test_helper"

class SuggestionsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

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

  test "suggestions are correctly displayed" do
    log_in_as("one-admin@example.com", "password")

    item = items(:one_author_stephen_king)
    visit("one/en/admin/authors/#{item.to_param}/edit")

    within(".suggestion-content") do
      assert(page.has_content?(suggestions(:one_comment1).content))
      find("a[data-action='click->toggle-display#reveal']").click

      # Deleted user should still be displayed in suggestions.
      assert(page.has_content?(users(:one_user_deleted).email))
    end
  end
end
