require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  test "create an item" do
    log_in_as("one-editor@example.com", "password")
    visit("/one/admin")
    click_on("Data")
    click_on("Authors")
    click_on("New Author")

    fill_in("Name", :with => "Test Author")
    fill_in("Age", :with => 25)
    fill_in("Site", :with => "https://google.com/")
    fill_in("Email", :with => "test@example.com")
    fill_in("Rank", :with => "1.25")
    select("Stephen King", :from => "Collaborator")
    select("Eng", :from => "Language")

    assert_difference("item_types(:one_author).items.count") do
      click_on("Create Author")
    end

    author = item_types(:one_author).items.last.behaving_as_type
    assert_equal("Test Author", author.public_send(:one_author_name_uuid))
    assert_equal("25", author.public_send(:one_author_age_uuid).to_s)
    assert_equal(
      "https://google.com/",
      author.public_send(:one_author_site_uuid))
    assert_equal("1.25", author.public_send(:one_author_rank_uuid))
    assert_equal(
      choices(:one_english).id.to_s,
      author.public_send(:one_author_language_uuid).to_s)
    assert_equal(
      items(:one_author_stephen_king).id.to_s,
      author.public_send(:one_author_collaborator_uuid).to_s)
  end

  test "create a multilingual item" do
    log_in_as("multilingual-editor@example.com", "password")
    visit("/multilingual/admin")
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
    visit("/one/admin")
    click_on("Data")
    click_on("Authors")
    first("a", :text => "Edit").click

    # Hack to get the ID of the author we're editing
    author_id = current_path[%r{(\d+)/edit$}, 1]

    fill_in("Name", :with => "Changed by test")
    select("Very Old", :from => "Collaborator")
    select("Eng", :from => "Language")

    assert_no_difference("Item.count") do
      click_on("Save Author")
    end

    author = Item.find(author_id).behaving_as_type
    assert_equal("Changed by test", author.public_send(:one_author_name_uuid))
  end

  test "delete an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin")
    click_on("Data")
    click_on("Authors")

    assert_difference("Item.count", -1) do
      first("a", :text => "Delete").click
    end
  end
end
