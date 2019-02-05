require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  include CSVFixtures

  test "import items from CSV" do
    log_in_as("one-editor@example.com", "password")
    visit("/one/en/admin/authors/import/new")

    attach_file("File", sample_csv_file.path)

    assert_difference("item_types(:one_author).items.count", 3) do
      click_on("Import")
    end

    # Should import the first three lines of the CSV:
    assert(page.has_content?("3 Authors imported"))
    # Should skip the two last lines of the CSV:
    # - Name missing for Jeff
    # - Decimal fields (rank) cannot contain commas or brackets for Albert
    assert(page.has_content?("2 skipped"))
  end

  def sample_csv_file
    csv_file_with_data <<~CSV
      name,nickname,ignore,rank
      Matthew,Matt,3,4
      Jenny,Jen,6,5.5
      John Doe,"No ,name",10,15.7
      ,Jeff,65,20.1
      Albert,Bert,33,"15,7"
    CSV
  end
end
