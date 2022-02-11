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
end
