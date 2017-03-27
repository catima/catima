require "test_helper"

class API::V1::ItemsTest < ActionDispatch::IntegrationTest
  include APITestHelpers

  test "GET items conforms to JSON schema" do
    get("/api/v1/catalogs/#{catalogs(:one).slug}/items")
    assert_response_schema("v1/items.json")
  end

  test "GET item conforms to JSON schema" do
    item = items(:one_author_stephen_king)
    get("/api/v1/catalogs/#{item.catalog.slug}/items/#{item.id}")
    assert_response_schema("v1/item.json")
  end

  # TODO: test 400 scenario
  # TODO: test 404 scenario
  # TODO: test inactive catalog scenario
  # TODO: test filter by item_type
end
