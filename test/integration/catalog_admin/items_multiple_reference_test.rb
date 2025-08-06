require "test_helper"

class CatalogAdmin::ItemMultipleReferenceTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "searches without filter" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(".availableReferences", :wait => 30) do
      find("input", :wait => 30).set("king")
    end

    within(".availableReferences") do
      # Available reference which correspond to the current fulltext search
      assert(page.has_text?("King"))
      # Available reference which doesn't correspond to the current fulltext search
      assert(page.has_no_text?("Old"))
    end

    within(".selectedReferences") do
      # Already selected reference which shouldn't be impacted by the current fulltext search
      assert(page.has_text?("Young"))
    end
  end

  test "paginates without filter" do
    insert_references

    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(".availableReferences", :wait => 30) do
      find("input").set("26")
    end

    assert(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("Author 26", :count => 1))
    refute(find("#item_one_author_other_collaborators_uuid_json-editor").has_text?("Old"))
  end

  test "displays the existing values without pagination" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within(".selectedReferences div.item", :wait => 30, :match => :first) do
      assert(page.has_text?("Young apprentice"))
    end
  end

  test "displays the existing values with pagination" do
    insert_references

    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    assert(page.has_css?(".availableReferences", :wait => 30))

    within(".availableReferences", :wait => 30) do
      find(".load-more").click
    end

    find("div.item", text: "Stephen King").click
    find("#item_one_author_other_collaborators_uuid_json-editor .referenceControls .btn-success").click
    find("input[type='submit']").click

    visit("/one/en/admin/authors/#{author.to_param}/edit")
    within(".selectedReferences", :wait => 30) do
      assert(page.has_text?("Stephen King"))
    end
  end

  private

  def insert_references
    author = Item.where("search_data_en LIKE '%Old%'").first
    30.times do |i|
      author = author.dup
      author.uuid = i
      author.data['one_author_name_uuid'] = "Author #{i}"
      author.search_data_en = "Author #{i}"
      author.save!
    end
  end
end
