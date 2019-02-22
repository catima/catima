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

  test "allows navigation from one result to another" do
    visit("/search/en")
    click_on("Advanced")
    fill_in(
      "advanced_search[criteria][search_vehicle_make_uuid][contains]",
      :with => "toyota"
    )
    click_on("Search")

    click_on("Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }

    click_on("Prius")
    click_on("Highlander")
    within("h1") { assert(page.has_content?("Highlander")) }
  end
end
