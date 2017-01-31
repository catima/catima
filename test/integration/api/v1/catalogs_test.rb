require "test_helper"

class API::V1::UsersTest < ActionDispatch::IntegrationTest
  include APITestHelpers

  test "GET catalogs conforms to JSON schema" do
    get("/api/v1/catalogs")
    assert_response_schema("v1/catalogs.json")
  end

  test "GET catalogs includes valid links" do
    get("/api/v1/catalogs")
    catalog = json_response.first
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
    assert_nil(json_response.find { |c| c["slug"] == "inactive" })
  end
end
