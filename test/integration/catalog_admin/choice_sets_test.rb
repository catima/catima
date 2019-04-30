require "test_helper"

class CatalogAdmin::ChoiceSetsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ChoiceSetHelper

  test "add a choice set with choices" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    # find("#addRootChoice").click
    fill_in("choice_set[choices_attributes][0][short_name_en]", :with => "Eng")
    fill_in("choice_set[choices_attributes][0][long_name_en]", :with => "English")

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

  test "add a child to a choice within a choice set" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set with children")
    # find("#addRootChoice").click
    fill_in("choice_set[choices_attributes][0][short_name_en]", :with => "En")
    fill_in("choice_set[choices_attributes][0][long_name_en]", :with => "English")

    all("a[title='Add children']")[0].click
    all("a[title='Add children']")[0].click

    fill_in("choice_set[choices_attributes][0][0][short_name_en]", :with => "US")
    fill_in("choice_set[choices_attributes][0][0][long_name_en]", :with => "United States")

    fill_in("choice_set[choices_attributes][0][1][short_name_en]", :with => "GB")
    fill_in("choice_set[choices_attributes][0][1][long_name_en]", :with => "Great Britain")

    click_on("Create choice set")

    set = catalogs(:one).choice_sets.where(:name => "Test Set with children").first!
    parent_choice = set.choices.select { |c| c if c.children.count.positive? }.first
    assert_equal(2, parent_choice.children.count)

    assert_equal("US", parent_choice.children[0].short_name)
    assert_equal("United States", parent_choice.children[0].long_name)
    assert_equal("GB", parent_choice.children[1].short_name)
    assert_equal("Great Britain", parent_choice.children[1].long_name)
  end

  test "add a choice set with a multilingual choice" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin/_choices")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    # click_on("Add choice")

    fill_in("choice_set[choices_attributes][0][short_name_de]", :with => "Ger")
    fill_in("choice_set[choices_attributes][0][long_name_de]", :with => "German")
    fill_in("choice_set[choices_attributes][0][short_name_en]", :with => "Eng")
    fill_in("choice_set[choices_attributes][0][long_name_en]", :with => "English")
    fill_in("choice_set[choices_attributes][0][short_name_fr]", :with => "Fre")
    fill_in("choice_set[choices_attributes][0][long_name_fr]", :with => "French")
    fill_in("choice_set[choices_attributes][0][short_name_it]", :with => "Ita")
    fill_in("choice_set[choices_attributes][0][long_name_it]", :with => "Italian")

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

  # test "add choice from existing item" do
  #   log_in_as("one-admin@example.com", "password")
  #
  #   author = items(:one_author_stephen_king)
  #   field = fields(:one_author_other_languages)
  #   visit("/one/en/admin/authors/#{author.to_param}/edit")
  #
  #   select_choice("#item_one_author_other_languages_uuid_container", "Eng")
  #   select_choice("#item_one_author_other_languages_uuid_container", "Spanish")
  #
  #   find("div[data-field='#{field.id}'] a", :visible => :all).click
  #
  #   # within("#choice-modal-#{field.uuid}") do
  #   #   fill_in("Short name", :with => "Fre")
  #   #   fill_in("Long name", :with => "French")
  #   #   click_on("Create")
  #   # end
  #   #
  #   # assert(page.has_text?("Fre"))
  #   assert(page.has_text?("Eng"))
  #   assert(page.has_text?("Spanish"))
  # end

  test "edit a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")
    first("a.choiceset-action-edit").click
    fill_in("Name", :with => "Changed")

    assert_no_difference("ChoiceSet.count", "Choice.count") do
      click_on("Update choice set")
    end

    set = catalogs(:one).choice_sets.where(:name => "Changed").first
    refute_nil(set)
  end

  test "edit a choice's child" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")
    first("a.choiceset-action-edit").click

    all("a[title='Add children']")[0].click

    fill_in("choice_set[choices_attributes][0][0][short_name_en]", :with => "first choice")
    fill_in("choice_set[choices_attributes][0][0][long_name_en]", :with => "first choice as a child")

    assert_difference 'Choice.count', 1 do
      click_on("Update choice set")
    end

    set = catalogs(:one).choice_sets.where(:name => "Languages").first
    assert_equal("first choice", set.choices.first.children.first.short_name)
    assert_equal("first choice as a child", set.choices.first.children.first.long_name)
  end

  test "delete a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")

    assert_difference("catalogs(:one).choice_sets.active.count", -1) do
      first("a.choiceset-action-deactivate").click
    end
  end

  test "delete a choice's child" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choices")

    first("a.choiceset-action-edit").click

    all("a[title='Add children']")[0].click
    fill_in("choice_set[choices_attributes][0][0][short_name_en]", :with => "first choice")
    fill_in("choice_set[choices_attributes][0][0][long_name_en]", :with => "first choice as a child")
    click_on("Update choice set")

    first("a.choiceset-action-edit").click
    all("a[title='Remove']")[1].click

    assert_difference("Choice.count", -1) do
      click_on("Update choice set")
    end
  end
end
