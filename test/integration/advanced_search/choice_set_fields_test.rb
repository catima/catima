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

    within('#advanced_search_criteria_search_vehicle_style_uuid_0_id') do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2)

      within(".css-26l3qy-menu") do # Within the filter list
        find('div', text: 'Sedan', match: :first, visible: false).click
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Camry'))
    refute(page.has_selector?('h4', text: 'Highlander'))
  end

  # TODO: fix test
  # test "search for authors by multiple single tag choice field" do
  #  visit("/one/en")
  #  click_on("Advanced")
  #
  #  find("#default_search_type").click
  #  within("#default_search_type") do
  #    click_on("Author")
  #  end
  #
  #  within all(".choiceset-search-container")[1] do
  #    within("#advanced_search_criteria_one_author_other_languages_uuid_0_id") do
  #      find(".css-vj8t7z").click # Click on the filter input
  #
  #      within(".css-11unzgr") do # Within the filter list
  #        find('div', text: "Spanish", match: :first).click
  #      end
  #    end
  #
  #    find(".fa.fa-plus").click
  #  end
  #
  #  select("exclude", :from => "advanced_search[criteria][one_author_other_languages_uuid][1][field_condition]")
  #
  #  within all(".choiceset-search-container")[2] do
  #    within("#advanced_search_criteria_one_author_other_languages_uuid_1_id") do
  #      find(".css-vj8t7z").click # Click on the filter input
  #      within(".css-11unzgr") do # Within the filter list
  #        find('div', text: "French", match: :first).click
  #      end
  #    end
  #  end
  #
  #  click_on("Search")
  #
  #  assert(page.has_selector?('h4', text: 'Stephen King'))
  #  refute(page.has_selector?('h4', text: 'Very Old'))
  # end

  test "search for authors by category field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within('#advanced_search_criteria_one_author_category_uuid_0_id') do
      find(".css-1wa3eu0-placeholder").click # Click on the filter input
      sleep(2)

      within(".css-26l3qy-menu") do # Within the filter list
        find('div', text: 'With category', match: :first, visible: false).click
      end
    end

    within('#advanced_search_criteria_one_author_category_uuid_0_id_condition') do
      find(".css-g1d714-ValueContainer").click # Click on the filter input
      sleep(2)

      within(".css-4ljt47-MenuList") do # Within the filter list
        find('div', text: 'Language origin', match: :first, visible: false).click
      end
    end

    fill_in(
      "advanced_search[criteria][one_author_category_uuid][0][category_criteria][exact]",
      :with => 'latin'
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Very Old'))
    refute(page.has_selector?('h4', text: 'Young apprentice'))
  end
end
