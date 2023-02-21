require "test_helper"

class CatalogAdmin::ChoiceSetsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "add a choice and add a choice to it" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choice_sets")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    select("default", :from => "choice_set[choice_set_type]")
    assert_difference("catalogs(:one).choice_sets.count") do
      click_on("Create choice set")
    end
    set = catalogs(:one).choice_sets.where(:name => "Test Set").first!
    visit("/one/en/admin/_choice_sets/#{set.id}/edit")
    click_on("New choice")
    fill_in("Short name", :with => "Eng")
    fill_in("Long name", :with => "English")
    assert_difference("Choice.count") do
      click_on("Create choice")
    end

    set = catalogs(:one).choice_sets.where(:name => "Test Set").first!
    assert_equal(1, set.choices.count)
    assert_equal("Eng", set.choices.first.short_name)
    assert_equal("English", set.choices.first.long_name)
  end

  test "add a choice set and add a multilingual choice" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin/_choice_sets")
    click_on("New choice set")
    fill_in("Name", :with => "Test Set")
    select("default", :from => "choice_set[choice_set_type]")
    assert_difference("catalogs(:multilingual).choice_sets.count") do
      click_on("Create choice set")
    end
    set = catalogs(:multilingual).choice_sets.where(:name => "Test Set").first!
    visit("/multilingual/en/admin/_choice_sets/#{set.id}/edit")

    click_on("New choice")
    fill_in("choice[short_name_en]", :with => "Eng")
    fill_in("choice[long_name_en]", :with => "English")
    fill_in("choice[short_name_fr]", :with => "Fre")
    fill_in("choice[long_name_fr]", :with => "French")
    fill_in("choice[short_name_it]", :with => "Ita")
    fill_in("choice[long_name_it]", :with => "Italian")
    fill_in("choice[short_name_de]", :with => "Ger")
    fill_in("choice[long_name_de]", :with => "German")

    assert_difference("Choice.count") do
      click_on("Create choice")
    end

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

  test "add choice from existing item" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    field = fields(:one_author_other_languages)

    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(find('#item_one_author_other_languages_uuid_json', visible: false).find(:xpath,".//..")) do
      find("a[data-target='#choice-modal-#{field.uuid}']", :visible => :all).click
    end
    sleep(2) # Wait for the ReactModal to fetch its data

    within("#choice-modal-#{field.uuid}") do
      fill_in("Short name", :with => "Fre")
      fill_in("Long name", :with => "French")
      click_on("Create")
    end
    sleep(2) # Wait for the ReactModal to close and update selected values

    assert(page.has_text?("Fre"))
    assert(page.has_text?("Eng"))
    assert(page.has_text?("Spanish"))
  end

  test "edit a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choice_sets")
    first("a.choiceset-action-edit").click
    fill_in("Name", :with => "Changed")

    assert_no_difference("ChoiceSet.count", "Choice.count") do
      click_on("Update choice set")
    end

    set = catalogs(:one).choice_sets.where(:name => "Changed").first
    refute_nil(set)
  end

  test "deactivate a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choice_sets")

    assert_difference("catalogs(:one).choice_sets.not_deactivated.count", -1) do
      first("a.choiceset-action-deactivate").click
    end

    assert(page.has_text?("Inactive"))
  end

  test "delete a choice" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_choice_sets")

    assert_difference("catalogs(:one).choice_sets.not_deleted.count", -1) do
      page.accept_alert(:wait => 2) do
        first("a.choiceset-action-delete").click
      end
      sleep 2 # Wait for page count to be correct
    end
  end
end
