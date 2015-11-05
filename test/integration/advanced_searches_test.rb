require "test_helper"

class AdvancedSearchesTest < ActionDispatch::IntegrationTest
  test "search for toyota excluding camry finds 2 matches" do
    visit("/search/en")
    click_on("Advanced")
    fill_in(
      "advanced_search[criteria][search_vehicle_make_uuid][contains]",
      :with => "toyota"
    )
    fill_in(
      "advanced_search[criteria][search_vehicle_model_uuid][excludes]",
      :with => "camry"
    )
    click_on("Search")

    assert(page.has_content?("Prius"))
    assert(page.has_content?("Highlander"))
    refute(page.has_content?("Camry"))
  end

  test "allows navigation from one result to another, and back to results" do
    visit("/search/en")
    click_on("Advanced")
    fill_in(
      "advanced_search[criteria][search_vehicle_make_uuid][contains]",
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
end
