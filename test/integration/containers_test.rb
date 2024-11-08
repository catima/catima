require "test_helper"

class ContainersTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "sends a contact request" do
    visit("/one/en/one-page")

    fill_in("Name", :with => "fake name")
    fill_in("Email", :with => "fake@email.ch")
    fill_in("Subject", :with => "subject")
    fill_in("Body", :with => "body")
    click_on("Send message")

    assert(page.has_content?("Message sent"))
  end

  test "has the required attribute for required fields" do
    visit("/one/en/one-page")

    assert(true, find_field('email')[:required])
    assert(true, find_field('body')[:required])
  end

  test "has an itemlist sorted by field ascending" do
    visit("/one/en/one-fasc")

    first_item = first(".media")
    last_item = all(".media").last

    assert(first_item.has_content?("Very first author"))
    assert(first_item.has_content?("very@first.com"))
    refute(first_item.has_content?("very@last.com"))

    # Items without primary field should be at the end of the sorted list
    assert(last_item.has_content?("Empty Author"))
  end

  test "has an itemlist sorted by field descending" do
    visit("/one/en/one-fdesc")

    first_item = first(".media")
    last_item = all(".media").last

    assert(first_item.has_content?("Very last author"))
    assert(first_item.has_content?("very@last.com"))
    refute(first_item.has_content?("very@first.com"))

    # Items without primary field should be at the end of the sorted list
    assert(last_item.has_content?("Empty Author"))
  end

  test "has an itemlist with a line style sorted by name field ascending" do
    visit("/one/en/line-one")

    select_sort = first("#asc-desc")
    first_level0_group = first(".level-0")
    first_level1_group = first(".level-1")

    assert(select_sort.has_content?("Ascending"))

    assert(first_level0_group.has_content?("A"))
    assert(first_level1_group.has_content?("Very first author"))
  end

  test "item with image show both title and thumbnail" do
    visit("/one/en/line-one")

    # Select the item with the image.
    within(".line__container > .level-0:first-child .level-1:nth-child(2) .line__group__item") do
      assert(page.has_content?("Author with images"), "The item should display the title 'Author with images'")
      assert(page.has_selector?("img"), "The item should display a thumbnail image")
    end
  end
end
