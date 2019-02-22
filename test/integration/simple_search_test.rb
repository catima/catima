require "test_helper"

class SimpleSearchTest < ActionDispatch::IntegrationTest
  setup do
    catalogs(:search).items.reindex
  end

  test "search for toyota finds 3 matches" do
    visit("/search/en")
    fill_in("q", :with => "Toyota")
    click_on("Search")

    assert(page.has_content?("Prius"))
    assert(page.has_content?("Highlander"))
    assert(page.has_content?("Camry"))
  end

  test "search for honda finds no matches" do
    visit("/search/en")
    fill_in("q", :with => "Honda")
    click_on("Search")

    refute(page.has_content?("Prius"))
    refute(page.has_content?("Highlander"))
    refute(page.has_content?("Camry"))
  end

  test "allows navigation from one result to another" do
    visit("/search/en")
    fill_in("q", :with => "Toyota")
    click_on("Search")

    click_on("Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }

    click_on("Camry Hybrid")
    within("h1") { assert(page.has_content?("Camry Hybrid")) }
    assert(page.has_content?("Highlander"))

    click_on("Camry")
    within("h1") { assert(page.has_content?("Camry")) }
    assert(page.has_content?("Camry Hybrid"))

    click_on("Prius")
    within("h1") { assert(page.has_content?("Prius")) }
    assert(page.has_content?("Camry"))

    click_on("Camry")
    within("h1") { assert(page.has_content?("Camry")) }
  end
end
