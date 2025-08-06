require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ItemReferenceHelper

  test "create an item" do
    log_in_as("one-editor@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")
    click_on("New Author")

    fill_in("Name", :with => "Test Author")
    fill_in("Age", :with => 25)
    fill_in("Site", :with => "https://google.com/")
    fill_in("Email", :with => "test@example.com")
    fill_in("Rank", :with => "1.25")

    add_single_reference('#item_one_author_collaborator_uuid_json-editor', 'Very Old')

    add_multiple_reference('#item_one_author_other_collaborators_uuid_json-editor', 'Very Old')
    add_multiple_reference('#item_one_author_other_collaborators_uuid_json-editor', 'Very Young')

    find("#item_one_author_other_collaborators_uuid_json-editor .referenceControls .btn-success").click

    within(find('#item_one_author_language_uuid_json', visible: false).find(:xpath, '..')) do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2) # Wait for the AsyncPaginate to populate
      within(".css-11unzgr") do # Within the filter list
        find('div', text: 'Eng', match: :first, visible: false).click
      end
    end

    within(find('#item_one_author_other_languages_uuid_json', visible: false).find(:xpath, '..')) do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2) # Wait for the AsyncPaginate to populate
      within(".css-11unzgr") do # Within the filter list
        find('div', text: 'Eng', match: :first, visible: false).click
      end
    end

    page.execute_script(
      "document.getElementById('item_one_author_birth_time_uuid_json').value = " \
      "'{\"Y\":2015, \"M\":12, \"D\":31, \"h\":14, \"m\":30, \"s\":17}';"
    )

    # Check that the category field is hidden when the option is not selected.
    # Can't use :visible => false because it will return true even when
    # the element is visible.
    assert_not page.has_css?('#item_language_category_uuid', :visible => true)

    # Select the category option.
    within(find('#item_one_author_category_uuid_json', visible: false).find(:xpath, '..')) do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2) # Wait for the AsyncPaginate to populate
      within(".css-11unzgr") do # Within the filter list
        find('div', text: 'With category', match: :first, visible: false).click
      end
    end

    # Check that category field is visible when the option is selected.
    assert page.has_css?('#item_language_category_uuid', :visible => true)

    assert_difference("item_types(:one_author).items.count") do
      click_on("Create Author")
    end

    author = item_types(:one_author).items.last.behaving_as_type
    assert_equal("Test Author", author.public_send(:one_author_name_uuid))
    assert_equal("25", author.public_send(:one_author_age_uuid).to_s)
    assert_equal("https://google.com/", author.public_send(:one_author_site_uuid))
    assert_equal("1.25", author.public_send(:one_author_rank_uuid))
    assert_equal("Vert", author.public_send(:one_author_favorite_color_uuid))
    assert_equal(choices(:one_english).id.to_s, author.public_send(:one_author_language_uuid).to_s)
    assert_equal(
      [choices(:one_english).id.to_s, choices(:one_spanish).id.to_s],
      author.public_send(:one_author_other_languages_uuid))
    assert_equal(items(:one_author_very_old).id.to_s, author.public_send(:one_author_collaborator_uuid).to_s)
    assert_equal(
      %i(one_author_very_old one_author_very_young).map { |i| items(i).id.to_s }.sort,
      author.public_send(:one_author_other_collaborators_uuid).sort)
  end

  test "create a multilingual item" do
    log_in_as("multilingual-editor@example.com", "password")
    visit("/multilingual/en/admin")
    click_on("Data")
    click_on("Authors")
    click_on("New Author")

    fill_in("Name", :with => "Test Author")
    fill_in("item[multilingual_author_bio_uuid_de]", :with => "German")
    fill_in("item[multilingual_author_bio_uuid_en]", :with => "English")
    fill_in("item[multilingual_author_bio_uuid_fr]", :with => "French")
    fill_in("item[multilingual_author_bio_uuid_it]", :with => "Italian")

    assert_difference("item_types(:multilingual_author).items.count") do
      click_on("Create Author")
    end

    author = item_types(:multilingual_author).items.last.behaving_as_type

    assert_equal(
      "Test Author",
      author.public_send(:multilingual_author_name_uuid))

    assert_equal("German", author.public_send(:multilingual_author_bio_uuid_de))
    assert_equal("English", author.public_send(:multilingual_author_bio_uuid_en))
    assert_equal("French", author.public_send(:multilingual_author_bio_uuid_fr))
    assert_equal("Italian", author.public_send(:multilingual_author_bio_uuid_it))
  end

  test "edit an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")
    first("a.item-action-edit").click

    # Hack to get the ID of the author we're editing
    author_id = current_path[%r{authors/(.+)/edit$}, 1]

    fill_in("Name", :with => "Changed by test")

    add_single_reference('#item_one_author_collaborator_uuid_json-editor', 'Very Old')

    within(find('#item_one_author_language_uuid_json', visible: false).find(:xpath, '..')) do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2)
      within(".css-11unzgr") do # Within the filter list
        find('div', text: 'Eng', match: :first, visible: false).click
      end
    end

    assert_no_difference("Item.count") do
      click_on("Save Author")
    end

    author = Item.find(author_id).behaving_as_type
    assert_equal("Changed by test", author.public_send(:one_author_name_uuid))
  end

  test "mark an item as ready for review" do
    log_in_as("reviewed-editor@example.com", "password")
    book = items(:reviewed_book_end_of_watch)
    visit("/reviewed/en/admin/books/#{book.to_param}/edit")
    check("Ready for review")
    click_on("Save Book")
    assert(book.reload.review.pending?)
  end

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

    click_on('Data')
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
