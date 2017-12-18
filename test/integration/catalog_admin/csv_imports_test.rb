require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  include CSVFixtures

  test "import items from CSV" do
    log_in_as("one-editor@example.com", "password")
    visit("/one/en/admin/authors/import/new")

    attach_file("File", sample_csv_file.path)

    assert_difference("item_types(:one_author).items.count", 2) do
      click_on("Import")
    end

    assert(page.has_content?("2 Authors imported"))
    assert(page.has_content?("1 skipped"))
  end

  def sample_csv_file
    csv_file_with_data <<~CSV
      name,nickname,ignore
      Matthew,Matt,3
      Jenny,Jen,6
      ,No name,10
    CSV
  end
end
