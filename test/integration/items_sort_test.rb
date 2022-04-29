require "test_helper"

class ItemsSortTest < ActionDispatch::IntegrationTest
  test "default sort should be by primary field ascending" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/authors?sort=list")

    first_item = first(".media")
    last_item = all(".media").last

    assert(first_item.has_content?("Very first author"))
    assert(first_item.has_content?("very@first.com"))
    refute(first_item.has_content?("very@last.com"))

    # Items without primary field should be at the end of the sorted list
    assert(last_item.has_content?("Empty Author"))
  end
end
