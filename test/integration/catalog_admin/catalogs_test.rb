require "test_helper"

class CatalogAdmin::CatalogsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "custom styles is correctly saved" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_style")

    # Select the "Titles" category.
    within("#general > .form-group:not(.form-group ~ .form-group)") do
      select("Impact")
      select("14 pt")
      click_on("B")
    end

    click_on("Save style")
    assert_equal(
      JSON.parse(catalogs(:one).style),
      {
        "main-title" => {
          "fontSize" => "14pt",
          "fontFamily" => "Impact, Charcoal, sans-serif",
          "fontWeight" => "bold"
        }
      }
    )
  end
end
