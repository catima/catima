require "test_helper"

class AdvancedSearch::DateTimeFieldTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include DatepickerHelper

  test "search for authors by exact datetime" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    fill_in(
      "advanced_search[criteria][one_author_birth_time_uuid][start][exact][D]",
      :with => "21"
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by before datetime" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select_day(
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_start_date",
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_calendar_icon_start_date",
      27
    )

    select(
      "before",
      :from => "advanced_search[criteria][one_author_birth_time_uuid][condition]"
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by outside datetime range" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select(
      "outside",
      :from => "advanced_search[criteria][one_author_birth_time_uuid][condition]"
    )

    select_day(
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_start_date",
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_calendar_icon_start_date",
      3
    )

    select_day(
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_end_date",
      "#advanced_search_criteria_one_author_birth_time_uuid_id-datetime_calendar_icon_end_date",
      26
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end
end
