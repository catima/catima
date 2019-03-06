require "test_helper"

class AdvancedSearchesTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "allows navigation from one result to another, and back to results" do
    visit("/search/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Vehicle")
    end

    fill_in(
      "advanced_search[criteria][search_vehicle_make_uuid][all_words]",
      :with => "toyota"
    )
    click_on("Search")

    click_on("Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }

    click_on("Next:")
    click_on("Previous:")
    within("h1") { assert(page.has_content?("Highlander")) }
    click_on("Back to search results")

    assert(page.has_content?("Prius"))
    assert(page.has_content?("Highlander"))
    assert(page.has_content?("Camry"))
  end

  test "displays the results in the alphabetical order" do
    visit("/search/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Vehicle")
    end

    fill_in(
      "advanced_search[criteria][search_vehicle_make_uuid][all_words]",
      :with => "toyota"
    )
    click_on("Search")

    items = all("h4")

    assert_equal("Camry", items[0].text)
    assert_equal("Camry Hybrid", items[1].text)
    assert_equal("Highlander", items[2].text)
  end
end
