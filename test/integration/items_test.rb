require "test_helper"

# rubocop:disable Metrics/ClassLength
class ItemsTest < ActionDispatch::IntegrationTest
  test "view items" do
    visit("/one/en/authors")
    within("body>.container") do
      refute(page.has_content?("Age"))
      assert(page.has_content?("Site"))
      assert(page.has_content?("Email"))
    end
  end

  test "view items in different languages" do
    visit("/multilingual/fr/authors")
    within("body>.container") do
      assert(page.has_content?("Biographie"))
    end

    visit("/multilingual/en/authors")
    within("body>.container") do
      assert(page.has_content?("Biography"))
    end
  end

  test "switch language and remain on same page" do
    author = items(:multilingual_author_example)
    visit("/multilingual/fr/authors/#{author.to_param}?key=value")
    within("body>.container") { assert(page.has_content?("français")) }
    within(".navbar-static-top") { click_on("English") }
    within("body>.container") { assert(page.has_content?("English")) }
    # Note that we expect the query param to be preserved
    assert_match(
      %r{/multilingual/en/authors/#{author.to_param}\?key=value$},
      current_url
    )
  end

  test "view item details" do
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")
    within("table") do
      assert(page.has_content?("Name"))
      assert(page.has_content?("Age"))
      assert(page.has_content?("Site"))
      assert(page.has_content?("Email"))
      assert(page.has_content?("Rank"))
      assert(page.has_content?("Biography"))

      assert(page.has_content?("Stephen King"))
      assert(page.has_content?("68"))
      assert(page.has_content?("stephenking.com/index.html"))
      assert(page.has_content?("sk@stephenking.com"))
      assert(page.has_content?("1.88891"))
      assert(page.has_content?("bio.doc"))
    end
  end

  test "view item details without empty fields" do
    author = items(:one_author_empty_fields)
    visit("/one/en/authors/#{author.to_param}")

    assert(page.has_content?("Empty Author"))
    refute(page.has_content?("Name"))
    refute(page.has_content?("Age"))
    refute(page.has_content?("Site"))
    refute(page.has_content?("Email"))
    refute(page.has_content?("Rank"))
    refute(page.has_content?("Collaborator"))
    refute(page.has_content?("Other Collaborator"))
    refute(page.has_content?("Biography"))
    refute(page.has_content?("Language"))
    refute(page.has_content?("Other Language"))
    refute(page.has_content?("Born"))
    refute(page.has_content?("Birth Time"))
    refute(page.has_content?("Birth Month"))
    refute(page.has_content?("Birthplace"))
    refute(page.has_content?("Picture"))
  end

  test "can't see item that isn't approved" do
    book = items(:reviewed_book_end_of_watch)
    visit("/reviewed/en/books/#{book.to_param}")
    assert(page.has_content?("Oops. Such an item doesn't exist."))
  end

  test "view item details with template override" do
    author = items(:one_author_stephen_king)
    with_customized_file("test/custom/views/items/show_author.html.erb",
                         "catalogs/one/views/items/show.html+authors.erb") do
      visit("/one/en/authors/#{author.to_param}")
    end
    assert(page.has_content?("This is a custom template"))
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Steve"))
    assert(page.has_content?("68"))
    assert(page.has_content?("stephenking.com/index.html"))
    assert(page.has_content?("sk@stephenking.com"))
    assert(page.has_content?("1.88891"))
    assert(page.has_content?("bio.doc"))
  end

  test "view item details with custom layout" do
    author = items(:one_author_stephen_king)
    with_customized_file("test/custom/views/layouts/application.html.erb",
                         "catalogs/one/views/layouts/application.html.erb") do
      visit("/one/en/authors/#{author.to_param}")
    end
    assert(page.has_content?("This is a custom layout"))
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Steve"))
    assert(page.has_content?("68"))
    assert(page.has_content?("stephenking.com/index.html"))
    assert(page.has_content?("sk@stephenking.com"))
    assert(page.has_content?("1.88891"))
    assert(page.has_content?("bio.doc"))
  end

  test "view items belonging to a choice" do
    apply_vehicle_styles
    visit("/search/en/vehicles?style=en-Sedan")

    assert(page.has_content?("Accord"))
    assert(page.has_content?("Prius"))
    assert(page.has_content?("Camry"))
    refute(page.has_content?("Highlander"))
  end

  test "view item with references from other items" do
    apply_book_references
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")

    within("body>.container") do
      assert(page.has_content?("Books"))
      assert(page.has_content?("End of Watch"))
      assert(page.has_content?("Finders Keepers"))
    end

    click_on("Finders Keepers")
    within("h1") { assert(page.has_content?("Finders Keepers")) }
  end

  test "view item with editor" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
    end
  end

  test "view item with editor and updater" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?('Updated by'))
    end
  end

  test "view item with editor and timestamps" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?(Time.current.year.to_s))
    end
  end

  test "view item with editor, updater and timestamps" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?('Updated by'))
      assert(page.has_content?(Time.current.year.to_s))
    end
  end

  test "allows navigation from one browsed item to another" do
    apply_vehicle_styles
    visit("/search/en/vehicles?style=en-Sedan")

    click_on("Accord")
    within("h1") { assert(page.has_content?("Accord")) }

    click_on("Camry")
    within("h1") { assert(page.has_content?("Camry")) }
    assert(page.has_content?("Accord"))
  end

  private

  def apply_vehicle_styles
    sedan = choices(:search_sedan)
    %w(honda_accord toyota_prius toyota_camry).each do |name|
      item = items(:"search_vehicle_#{name}")
      item.data["search_vehicle_style_uuid"] = sedan.id
      item.save!
    end

    suv = choices(:search_suv)
    %w(toyota_highlander).each do |name|
      item = items(:"search_vehicle_#{name}")
      item.data["search_vehicle_style_uuid"] = suv.id
      item.save!
    end
  end

  def apply_book_references
    author = items(:one_author_stephen_king)
    %w(end_of_watch finders_keepers).each do |name|
      book = items(:"one_book_#{name}")
      book.data["one_book_author_uuid"] = author.id
      book.save!
    end
  end
end
