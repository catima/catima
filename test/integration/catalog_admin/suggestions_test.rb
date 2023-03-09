require "test_helper"

class CatalogAdmin::SuggestionsTest < ActionDispatch::IntegrationTest
  include ItemReferenceHelper

  test "view suggestions on item edit page" do
    log_in_as("one-admin@example.com", "password")
    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    assert(page.has_content?("Suggestions"))
    assert(page.has_content?(/existing_suggestion1/i))
  end

  test "disable suggestions on item type" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin")
    click_on("Author")
    click_on("Edit item type")
    uncheck("item_type_suggestions_activated")
    click_on("Save item type")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    refute(page.has_content?("Suggestions"))
    refute(page.has_content?(/existing_suggestion1/i))
  end

  test "deleted user is still correctly displayed" do
    log_in_as("one-admin@example.com", "password")

    item = items(:one_author_stephen_king)
    visit("one/en/admin/authors/#{item.to_param}/edit")

    within(".suggestion-content") do
      assert(page.has_content?(suggestions(:one_comment1).content))
      first("a.toggle-suggestion").click

      # Deleted user should still be displayed in suggestions.
      assert(page.has_content?(users(:one_user_deleted).email))
    end
  end
end
