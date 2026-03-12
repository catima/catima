require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ItemReferenceHelper

  test "multilingual i18n formatted text do not display raw input" do
    log_in_as("multilingual-admin@example.com", "password")

    book = items(:multilingual_book_formatted_i18n)
    visit("/multilingual/en/admin/books/#{book.to_param}/edit")

    # We use assert_not with visible => true because visible => false will
    # return true even when the element is visible.
    assert_not page.has_css?('#item_multilingual_book_notes_uuid_fr', :visible => true)
    assert_not page.has_css?('#item_multilingual_book_notes_uuid_it', :visible => true)
    assert_not page.has_css?('#item_multilingual_book_notes_uuid_en', :visible => true)
    assert_not page.has_css?('#item_multilingual_book_notes_uuid_de', :visible => true)
  end
end
