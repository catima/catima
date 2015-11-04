require "test_helper"

class SimpleSearchTest < ActionDispatch::IntegrationTest
  setup do
    catalogs(:search).items.reindex
  end

  test "search for toyota finds 3 matches" do
    visit("/search/en")
    fill_in("q", :with => "Toyota")
    click_on("Submit")

    assert(page.has_content?("Prius"))
    assert(page.has_content?("Highlander"))
    assert(page.has_content?("Camry"))
  end

  test "search for honda finds no matches" do
    visit("/search/en")
    fill_in("q", :with => "Honda")
    click_on("Submit")

    refute(page.has_content?("Prius"))
    refute(page.has_content?("Highlander"))
    refute(page.has_content?("Camry"))
  end

  test "allows navigation from one result to another" do
    visit("/search/en")
    fill_in("q", :with => "Toyota")
    click_on("Submit")

    click_on("Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }
    refute(page.has_content?("Previous:"))

    click_on("Next: Camry")
    within("h1") { assert(page.has_content?("Camry")) }
    assert(page.has_content?("Previous: Highlander"))

    click_on("Next: Prius")
    within("h1") { assert(page.has_content?("Prius")) }
    assert(page.has_content?("Previous: Camry"))
    refute(page.has_content?("Next:"))

    click_on("Previous: Camry")
    within("h1") { assert(page.has_content?("Camry")) }
  end
end
