require "test_helper"

class CatalogAdmin::ItemMultipleReferenceTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "searches without filter" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    sleep 2 # Wait for Ajax request to complete

    within(".availableReferences") do
      find("input").set("king")
    end

    assert(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("King", :count => 1))
    refute(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("Old"))
  end

  test "paginates without filter" do
    # Populates the references search container with more than 25 items to paginate
    author = Item.where("search_data_en LIKE '%Old%'").first
    30.times do |i|
      author = author.dup
      author.uuid = i
      author.data['one_author_name_uuid'] = "Author #{i}"
      author.search_data_en = "Author #{i}"
      author.save!
    end

    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(".availableReferences", :wait => 30) do
      find("input").set("26")
    end

    assert(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("Author 26", :count => 1))
    refute(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("Old"))
  end
end
