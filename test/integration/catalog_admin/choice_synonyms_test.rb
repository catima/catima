require "test_helper"

class CatalogAdmin::ChoiceSynonymsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ChoiceSetHelper

  test "adds a synonym to a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")

    first("a.choiceset-action-edit").click

    click_on("Synonyms")

    first("a#addRootSynonym").click
    within("#synonym_select_1_container") do
      find("span.ant-select-selection.ant-select-selection--single").click # Click on the filter input
    end
    within("div.ant-select-dropdown:not(.ant-select-dropdown-hidden)") do
      find("span", text: "Eng", :match => :first).click
    end
    all("input[name^=\"choice_synonyms\"]")[1].set("Eng (US)")
    click_on("Save")

    click_on("Synonyms")

    assert_equal(all("input[name^=\"choice_synonyms\"]")[1].value, "Eng (US)")
  end

  test "edits a synonym of a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")

    first("a.choiceset-action-edit").click

    click_on("Synonyms")

    first("a#addRootSynonym").click
    within("#synonym_select_0_container") do
      find("span.ant-select-selection.ant-select-selection--single").click # Click on the filter input
    end
    within("div.ant-select-dropdown") do
      find("span", text: "Eng", :match => :first).click
    end
    first("input[name^=\"choice_synonyms\"]").set("Eng (AU)")
    click_on("Save")

    click_on("Synonyms")

    assert_equal(first("input[name^=\"choice_synonyms\"]").value, "Eng (AU)")
  end

  test "removes a synonym from a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")

    first("a.choiceset-action-edit").click

    click_on("Synonyms")
    find("a.btn i.fa.fa-trash").click
    click_on("Save")
    click_on("Cancel")

    click_on("Synonyms")

    refute(page.has_css?("input[name^=\"choice_synonyms\"]"))
  end
end
