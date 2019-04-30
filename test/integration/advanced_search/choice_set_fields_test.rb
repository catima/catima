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

    find("span.ant-select-arrow").click # Click on the filter input
    find("span", text: "Sedan", match: :first).click

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Camry'))
    refute(page.has_selector?('h4', text: 'Highlander'))
  end

  test "search for authors by multiple single tag choice field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within all(".choiceset-search-container")[1] do
      find(".fa.fa-plus").click
      find("span.ant-select-arrow").click # Click on the filter input
    end
    find("span", text: "Spanish", match: :first).click

    select("exclude", :from => "advanced_search[criteria][one_author_other_languages_uuid][1][field_condition]")

    within all(".choiceset-search-container")[2] do
      find("span.ant-select-arrow").click # Click on the filter input
    end
    find("span", text: "French", match: :first).click

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by category field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within all(".choiceset-search-container")[0] do
      find("span.ant-select-arrow").click # Click on the filter input
    end
    find("span", text: "French", match: :first).click

    within("#advanced_search_criteria_one_author_language_uuid_0_id_condition") do
      find(".select__indicators").click # Click on the filter input
    end

    within(".select__menu") do
      all("div")[1].click
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
