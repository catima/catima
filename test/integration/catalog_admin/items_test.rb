require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ItemReferenceHelper

  test "delete an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")

    assert_difference("Item.count", -1) do
      page.accept_alert(:wait => 2) do
        first("a.item-action-delete").click
      end
      sleep 2 # Wait for page count to be correct
    end
  end

  test "duplicate an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")

    assert_difference("Item.count", +1) do
      first("a.item-action-duplicate").click
      click_on("Create Author")
    end
  end

  test "creating items for item types without fields is not enabled" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin")
    click_on("New item type")
    fill_in("item_type[name_en]", :with => "Computer")
    fill_in("item_type[name_plural_en]", :with => "Computers")
    fill_in("Slug (plural)", :with => "computers")

    assert_difference("catalogs(:one).item_types.count") do
      click_on("Create item type")
    end

    click_on("Data")
    click_on('Computers')
    assert(page.has_content?('This item type does not have any fields.'))
  end

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
