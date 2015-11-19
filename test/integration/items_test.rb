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

  test "switch language and remain on same page" do
    author = items(:multilingual_author_example)
    visit("/multilingual/fr/authors/#{author.to_param}?key=value")
    within("body>.container") { assert(page.has_content?("Français")) }
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

  test "view items belonging to a choice" do
    apply_vehicle_styles
    visit("/search/en/vehicles?style=en-Sedan")

    assert(page.has_content?("Accord"))
    assert(page.has_content?("Prius"))
    assert(page.has_content?("Camry"))
    refute(page.has_content?("Highlander"))
  end

  test "allows navigation from one browsed item to another" do
    apply_vehicle_styles
    visit("/search/en/vehicles?style=en-Sedan")

    click_on("Accord")
    within("h1") { assert(page.has_content?("Accord")) }
    refute(page.has_content?("Previous:"))

    click_on("Next: Camry")
    within("h1") { assert(page.has_content?("Camry")) }
    assert(page.has_content?("Previous: Accord"))

    click_on("Back to search results")
    assert_match(%r{/search/en/vehicles\?style=en-Sedan$}, current_url)
  end

  private

  def apply_vehicle_styles
    sedan = choices(:search_sedan)
    %w(honda_accord toyota_prius toyota_camry).each do |name|
      item = items(:"search_vehicle_#{name}")
      item.data_will_change!
      item.data["search_vehicle_style_uuid"] = sedan.id
      item.save!
    end

    suv = choices(:search_suv)
    %w(toyota_highlander).each do |name|
      item = items(:"search_vehicle_#{name}")
      item.data_will_change!
      item.data["search_vehicle_style_uuid"] = suv.id
      item.save!
    end
  end
end
