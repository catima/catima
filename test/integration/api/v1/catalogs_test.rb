require "test_helper"

class API::V1::CatalogsTest < ActionDispatch::IntegrationTest
  include APITestHelpers

  test "GET catalogs conforms to JSON schema" do
    get("/api/v1/catalogs")
    assert_response_schema("v1/catalogs.json")
  end

  test "GET catalogs honors page size" do
    get("/api/v1/catalogs?page_size=1")
    assert_equal(1, json_response["page_size"])
    assert_equal(1, json_response["catalogs"].size)

    get("/api/v1/catalogs?page_size=2")
    assert_equal(2, json_response["page_size"])
    assert_equal(2, json_response["catalogs"].size)
  end

  test "GET catalogs includes valid links" do
    get("/api/v1/catalogs")
    catalog = json_response["catalogs"].first
    assert_equal(
      "http://localhost:3000/api/v1/catalogs/#{catalog['slug']}",
      catalog["_links"]["self"]
    )
    assert_equal(
      "http://localhost:3000/#{catalog['slug']}",
      catalog["_links"]["html"]
    )
  end

  test "GET catalogs doesn't include inactive catalogs" do
    get("/api/v1/catalogs")
    assert_nil(json_response["catalogs"].find { |c| c["slug"] == "inactive" })
  end

  test "GET catalog conforms to JSON schema" do
    get("/api/v1/catalogs/#{catalogs(:one).slug}")
    assert_response_schema("v1/catalog.json")
  end
end
