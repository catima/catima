require "test_helper"

# rubocop:disable Metrics/ClassLength
class AdvancedSearch::ReferenceFieldTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include DatepickerHelper

  test "search for authors by single tag reference field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within("#advanced_search_criteria_one_author_collaborator_uuid_0_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Very Old", match: :first).click
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
    refute(page.has_selector?('h4', text: 'Very Young'))
  end

  test "search for authors by multiple single tag reference field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within(".reference-search-container", match: :first) do
      within("#advanced_search_criteria_one_author_collaborator_uuid_0_exact-editor") do
        find(".css-vj8t7z").click # Click on the filter input

        within(".css-11unzgr") do # Within the filter list
          find('div', text: "Very Old", match: :first).click
        end
      end

      find(".fa.fa-plus").click
    end

    select("or", :from => "advanced_search[criteria][one_author_collaborator_uuid][1][field_condition]")

    within all(".reference-search-container")[1] do
      within("#advanced_search_criteria_one_author_collaborator_uuid_1_exact-editor") do
        find(".css-vj8t7z").click # Click on the filter input
        within(".css-11unzgr") do # Within the filter list
          find('div', text: "Very Young", match: :first).click
        end
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    assert(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by multiple single tag reference field with or selector" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    select("or", :from => "advanced_search[criteria][one_author_collaborator_uuid][0][field_condition]")
    within(".reference-search-container", match: :first) do
      within("#advanced_search_criteria_one_author_collaborator_uuid_0_exact-editor") do
        find(".css-vj8t7z").click # Click on the filter input

        within(".css-11unzgr") do # Within the filter list
          find('div', text: "Very Old", match: :first).click
        end
      end

      find(".fa.fa-plus").click
    end

    select("or", :from => "advanced_search[criteria][one_author_collaborator_uuid][1][field_condition]")

    within all(".reference-search-container")[1] do
      within("#advanced_search_criteria_one_author_collaborator_uuid_1_exact-editor") do
        find(".css-vj8t7z").click # Click on the filter input
        within(".css-11unzgr") do # Within the filter list
          find('div', text: "Very Young", match: :first).click
        end
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    assert(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by multiple tag reference field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within("#advanced_search_criteria_one_author_other_collaborators_uuid_0_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Very Old", match: :first).click
      end
    end

    find('.choiceset-search-container', match: :first).click

    within("#advanced_search_criteria_one_author_other_collaborators_uuid_0_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Stephen King", match: :first).click
      end
    end

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Very Young'))
  end

  test "search for authors by several multiple tag reference field" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    # First multiple input reference
    within("#advanced_search_criteria_one_author_other_collaborators_uuid_0_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Very Old", match: :first).click
      end
    end

    find('.choiceset-search-container', match: :first).click

    within all(".reference-search-container")[1] do
      within("#advanced_search_criteria_one_author_other_collaborators_uuid_0_exact-editor") do
        find(".css-vj8t7z").click # Click on the filter input

        within(".css-11unzgr") do # Within the filter list
          find('div', text: "Stephen King", match: :first).click
        end
      end

      find(".fa.fa-plus").click
    end

    # Second multiple input reference
    select("exclude", :from => "advanced_search[criteria][one_author_other_collaborators_uuid][1][field_condition]")
    within("#advanced_search_criteria_one_author_other_collaborators_uuid_1_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Stephen King", match: :first).click
      end
    end

    click_on("Search")

    refute(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Young'))
  end

  test "search for authors by field of reference" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within(".single-reference-filter", match: :first) do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Email", match: :first).click
      end
    end

    fill_in(
      "advanced_search[criteria][one_author_collaborator_uuid][0][exact]",
      :with => "so@old.com"
    )

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Stephen King'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by date field of reference" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within all(".single-reference-filter")[1] do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Most Active Month", match: :first).click
      end
    end

    select("June", :from => "advanced_search[criteria][one_author_other_collaborators_uuid][0][start][exact][M]")

    click_on("Search")

    assert(page.has_selector?('h4', text: 'Very Young'))
    assert(page.has_selector?('h4', text: 'Young apprentice'))
    refute(page.has_selector?('h4', text: 'Very Old'))
  end

  test "search for authors by multiple tag reference field AND with a filter by attribute" do
    visit("/one/en")
    click_on("Advanced")

    find("#default_search_type").click
    within("#default_search_type") do
      click_on("Author")
    end

    within("#advanced_search_criteria_one_author_other_collaborators_uuid_0_exact-editor") do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Very Old", match: :first).click
      end
    end

    within all(".reference-search-container")[1] do
      find(".fa.fa-plus").click
    end

    within all(".reference-search-container")[2] do
      find(".css-vj8t7z").click # Click on the filter input

      within(".css-11unzgr") do # Within the filter list
        find('div', text: "Name", match: :first).click
      end

      fill_in(
        "advanced_search[criteria][one_author_other_collaborators_uuid][1][exact]",
        :with => "Young apprentice"
      )
    end

    click_on("Search")

    refute(page.has_selector?('h4', text: 'Young apprentice'))
    refute(page.has_selector?('h4', text: 'Very Young'))
  end
end
# rubocop:enable Metrics/ClassLength
