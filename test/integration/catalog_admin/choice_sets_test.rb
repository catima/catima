require "test_helper"

class CatalogAdmin::ChoiceSetsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "add choice from existing item" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    field = fields(:one_author_other_languages)

    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(find('#item_one_author_other_languages_uuid_json', visible: false).find(:xpath, ".//..")) do
      find("a[data-bs-target='#choice-modal-#{field.uuid}']", :visible => :all).click
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
