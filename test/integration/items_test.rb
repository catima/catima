require "test_helper"

class ItemsTest < ActionDispatch::IntegrationTest
  test "view items" do
    visit("/one/en/authors")
    within("body>.container") do
      assert(page.has_content?("Age"))
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

  test "view item details with template override" do
    author = items(:one_author_stephen_king)
    with_customized_file("test/custom/items/show_author.html.erb",
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
    with_customized_file("test/custom/layouts/application.html.erb",
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
end
