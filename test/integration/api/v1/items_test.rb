require "test_helper"

class API::V1::ItemsTest < ActionDispatch::IntegrationTest
  include APITestHelpers

  test "GET items conforms to JSON schema" do
    get("/api/v1/catalogs/#{catalogs(:one).slug}/items")
    assert_response_schema("v1/items.json")
  end

  test "GET items with bad item_type results in 400 error" do
    get("/api/v1/catalogs/#{catalogs(:one).slug}/items?item_type=bad-slug")
    assert_response(:bad_request)
  end

  test "GET items with bad catalog results in 404 error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get("/api/v1/catalogs/bad-catalog-slug/items")
    end
  end

  test "GET items with inactive catalog results in 404 error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get("/api/v1/catalogs/#{catalogs(:inactive).id}/items")
    end
  end

  test "GET items honors page size" do
    get("/api/v1/catalogs/#{catalogs(:one).slug}/items?page_size=1")
    assert_equal(1, json_response["page_size"])
    assert_equal(1, json_response["items"].size)

    get("/api/v1/catalogs/#{catalogs(:one).slug}/items?page_size=2")
    assert_equal(2, json_response["page_size"])
    assert_equal(2, json_response["items"].size)
  end

  test "GET items can be filtered by item type" do
    catalog = catalogs(:one)
    desired_type = item_types(:one_book)
    other_type = item_types(:one_author)

    get("/api/v1/catalogs/#{catalog.slug}/items?item_type=#{desired_type.slug}")
    assert_response_schema("v1/items.json")
    assert_match(/"item_type_id":#{desired_type.id}\b/, response.body)
    refute_match(/"item_type_id":#{other_type.id}\b/, response.body)
  end

  test "GET item conforms to JSON schema" do
    item = items(:one_author_stephen_king)
    get("/api/v1/catalogs/#{item.catalog.slug}/items/#{item.id}")
    assert_response_schema("v1/item.json")
  end

  test "GET item with wrong catalog results in in 404 error" do
    item = items(:one_author_stephen_king)
    other_catalog = catalogs(:two)

    assert_raises(ActiveRecord::RecordNotFound) do
      get("/api/v1/catalogs/#{other_catalog.slug}/items/#{item.id}")
    end
  end

  test "GET item pending review results in in 404 error" do
    item = items(:reviewed_book_harry_potter_pending)

    assert_raises(ActiveRecord::RecordNotFound) do
      get("/api/v1/catalogs/#{item.catalog.slug}/items/#{item.id}")
    end
  end
end
