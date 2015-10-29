require "test_helper"

class CatalogAdmin::ChoiceSetsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "add a choice set with choices" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin/_choices")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    click_on("Add choice")
    fill_in("Short name", :with => "Eng")
    fill_in("Long name", :with => "English")

    assert_difference("catalogs(:one).choice_sets.count") do
      assert_difference("Choice.count") do
        click_on("Create choice set")
      end
    end

    set = catalogs(:one).choice_sets.where(:name => "Test Set").first!
    assert_equal(1, set.choices.count)
    assert_equal("Eng", set.choices.first.short_name)
    assert_equal("English", set.choices.first.long_name)
  end

  test "add a choice set with a multilingual choice" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/admin/_choices")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    click_on("Add choice")

    fill_in("Short name de", :with => "Ger")
    fill_in("Long name de", :with => "German")
    fill_in("Short name en", :with => "Eng")
    fill_in("Long name en", :with => "English")
    fill_in("Short name fr", :with => "Fre")
    fill_in("Long name fr", :with => "French")
    fill_in("Short name it", :with => "Ita")
    fill_in("Long name it", :with => "Italian")

    assert_difference("catalogs(:multilingual).choice_sets.count") do
      assert_difference("Choice.count") do
        click_on("Create choice set")
      end
    end

    set = catalogs(:multilingual).choice_sets.where(:name => "Test Set").first!
    assert_equal(1, set.choices.count)

    assert_equal("Ger", set.choices.first.short_name_de)
    assert_equal("German", set.choices.first.long_name_de)
    assert_equal("Eng", set.choices.first.short_name_en)
    assert_equal("English", set.choices.first.long_name_en)
    assert_equal("Fre", set.choices.first.short_name_fr)
    assert_equal("French", set.choices.first.long_name_fr)
    assert_equal("Ita", set.choices.first.short_name_it)
    assert_equal("Italian", set.choices.first.long_name_it)
  end

  test "edit a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin/_choices")
    first("a", :text => "Edit").click
    fill_in("Name", :with => "Changed")

    assert_no_difference("ChoiceSet.count", "Choice.count") do
      click_on("Update choice set")
    end

    set = catalogs(:one).choice_sets.where(:name => "Changed").first
    refute_nil(set)
  end

  test "delete a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin/_choices")

    assert_difference("catalogs(:one).choice_sets.active.count", -1) do
      first("a", :text => "Deactivate").click
    end
  end
end
