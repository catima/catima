require "test_helper"

class AdvancedSearch::SimpleFieldsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "search for toyota excluding camry finds 2 matches" do
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

    select("exclude", :from => "advanced_search[criteria][search_vehicle_model_uuid][field_condition]")
    select("at least one word", :from => "advanced_search[criteria][search_vehicle_model_uuid][condition]")
    fill_in(
      "advanced_search[criteria][search_vehicle_model_uuid][one_word]",
      :with => "camry"
    )

    click_on("Search")

    assert(page.has_content?("Prius"))
    assert(page.has_content?("Highlander"))
    refute(page.has_content?("Camry"))
  end

  test "search for vehicles by number of doors" do
    visit("/search/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Vehicle")
    end

    select("less than or equal", :from => "advanced_search[criteria][search_vehicle_doors_uuid][condition]")
    fill_in(
      "advanced_search[criteria][search_vehicle_doors_uuid][less_than_or_equal_to]",
      :with => 3
    )

    click_on("Search")

    assert(page.has_content?("Camry Hybrid"))
    assert(page.has_content?("Prius"))
    assert(page.has_content?("XJ6"))
    refute(page.has_content?("Highlander"))
  end

  test "search for authors by boolean field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select("Yes", :from => "advanced_search[criteria][one_author_deceased_uuid][exact]")

    click_on("Search")

    assert(page.has_content?("Very Old"))
    refute(page.has_content?("Stephen King"))
  end

  test "search for authors by decimal field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select("greater than", :from => "advanced_search[criteria][one_author_rank_uuid][condition]")
    fill_in(
      "advanced_search[criteria][one_author_rank_uuid][greater_than]",
      :with => "2.1"
    )

    click_on("Search")

    assert(page.has_content?("Very Old"))
    refute(page.has_content?("Stephen King"))
  end

  test "search for authors by editor field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select("at least one word", :from => "advanced_search[criteria][one_author_editor_uuid][condition]")

    fill_in(
      "advanced_search[criteria][one_author_editor_uuid][one_word]",
      :with => "user"
    )
    click_on("Search")

    assert(page.has_content?("Stephen King"))
    refute(page.has_content?("Very Young"))
  end

  test "search for authors by email field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select("exclude", :from => "advanced_search[criteria][one_author_email_uuid][field_condition]")
    select("at least one word", :from => "advanced_search[criteria][one_author_email_uuid][condition]")

    fill_in(
      "advanced_search[criteria][one_author_email_uuid][one_word]",
      :with => "@stephenking.com"
    )
    click_on("Search")

    refute(page.has_content?("Stephen King"))
  end

  test "search for authors by url field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    fill_in(
      "advanced_search[criteria][one_author_site_uuid][all_words]",
      :with => "http://stephenking.com/index.html"
    )
    click_on("Search")

    assert(page.has_content?("Stephen King"))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end
end
