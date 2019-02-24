require "test_helper"

class SimpleSearchTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

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

  test "displays the results in the alphabetical order" do
    visit("/search/en")
    fill_in("q", :with => "Toyota")
    click_on("Search")

    items = all("h4")

    assert_equal("Camry", items[0].text)
    assert_equal("Camry Hybrid", items[1].text)
    assert_equal("Highlander", items[2].text)
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

    click_on("Camry")
    within("h1") { assert(page.has_content?("Camry")) }
    refute(page.has_content?("Previous:"))

    click_on("Camry Hybrid")
    within("h1") { assert(page.has_content?("Camry Hybrid")) }
    assert(page.has_content?("Previous: Camry"))

    click_on("Next: Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }
    assert(page.has_content?("Previous: Camry Hybrid"))

    click_on("Prius")
    within("h1") { assert(page.has_content?("Prius")) }
    assert(page.has_content?("Previous: Highlander"))
    refute(page.has_content?("Next:"))

    click_on("Previous: Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }
  end
end
