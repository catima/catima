require "test_helper"

class JsonConfigTest < ActiveSupport::TestCase
  include CustomizedFiles

  test "loads default fields.json" do
    config = JsonConfig.default.load("fields.json")
    expected_config = {
      "DateTime" => {
        "display_components" => [],
        "editor_components" => ["DateTimeInput"]
      },
      "ChoiceSet" => {
        "display_components" => [],
        "editor_components" => ["ChoiceSetInput"]
      },
      "ComplexDatation" => {
        "display_components" => [],
        "editor_components" => ["ComplexDatationInput"]
      },
      "Geometry" => {
        "display_components" => [],
        "editor_components" => ["GeoEditor"]
      }
    }
    assert_equal(expected_config, config)
  end

  test "falls back to default fields.json if no override present" do
    catalog = catalogs(:one)
    config = JsonConfig.for_catalog(catalog).load("fields.json")
    expected_config = {
      "DateTime" => {
        "display_components" => [],
        "editor_components" => ["DateTimeInput"]
      },
      "ChoiceSet" => {
        "display_components" => [],
        "editor_components" => ["ChoiceSetInput"]
      },
      "ComplexDatation" => {
        "display_components" => [],
        "editor_components" => ["ComplexDatationInput"]
      },
      "Geometry" => {
        "display_components" => [],
        "editor_components" => ["GeoEditor"]
      }
    }
    assert_equal(expected_config, config)
  end
end
