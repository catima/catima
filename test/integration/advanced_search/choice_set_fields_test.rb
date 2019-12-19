require "test_helper"

class AdvancedSearch::ChoiceSetFieldTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "search for cars by single tag choice" do
    visit("/search/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Vehicle")
    end

    within("#advanced_search_criteria_search_vehicle_style_uuid_0_id") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Sedan", match: :first).click
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Camry'))
    refute(page.has_selector?('h4', text: 'Highlander'))
  end

  test "search for authors by category field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within("#advanced_search_criteria_one_author_language_uuid_0_id") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "French", match: :first).click
      end
    end

    within("#advanced_search_criteria_one_author_language_uuid_0_id_condition") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Language origin", match: :first).click
      end
    end

    fill_in(
      "advanced_search[criteria][one_author_language_uuid][0][category_criteria][exact]",
      :with => 'latin'
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Very Old'))
    refute(page.has_selector?('h4', text: 'Young apprentice'))
  end
end
