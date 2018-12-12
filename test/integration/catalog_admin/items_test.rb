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

    sleep 2
    
    add_single_reference('#item_one_author_collaborator_uuid_json-editor', 'Very Old')

    add_multiple_reference('#item_one_author_other_collaborators_uuid_json-editor', 'Very Old')
    add_multiple_reference('#item_one_author_other_collaborators_uuid_json-editor', 'Very Young')

    first('#item_one_author_other_collaborators_uuid_json-editor-select').click

    select("Eng", :from => "Language")
    select("Eng", :from => "Other Languages")
    select("Spanish", :from => "Other Languages")
    page.execute_script(
      "document.getElementById('item_one_author_birth_time_uuid_json').value = " \
        "'{\"Y\":2015, \"M\":12, \"D\":31, \"h\":14, \"m\":30, \"s\":17}';"
    )

    assert_difference("item_types(:one_author).items.count") do
      click_on("Create Author")
    end

    author = item_types(:one_author).items.last.behaving_as_type
    assert_equal("Test Author", author.public_send(:one_author_name_uuid))
    assert_equal("25", author.public_send(:one_author_age_uuid).to_s)
    assert_equal("https://google.com/", author.public_send(:one_author_site_uuid))
    assert_equal("1.25", author.public_send(:one_author_rank_uuid))
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
    first(:button, 'Actions').click
    click_on('Edit')

    # Hack to get the ID of the author we're editing
    author_id = current_path[%r{authors/(.+)/edit$}, 1]

    fill_in("Name", :with => "Changed by test")

    add_single_reference('#item_one_author_collaborator_uuid_json-editor', 'Very Old')

    select("Eng", :from => "Language")

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
        first('button', text: 'Actions').click
        first('a', text: 'Delete').click
      end
      sleep 2
    end
  end

  test "duplicate an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")

    assert_difference("Item.count", +1) do
      first("button", :text => "Actions").click
      first("a", :text => "Duplicate").click
      sleep 2 # Wait to initialize JS
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
end
