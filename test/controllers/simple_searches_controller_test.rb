require "test_helper"

class SimpleSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @catalog = catalogs(:one)
    Item.reindex
  end

  test "create defaults to prefix matching when not specified" do
    post("/#{@catalog.slug}/en/search/simple", :params => { :q => "kin" })

    follow_redirect!
    assert_response(:success)
    assert_includes(@response.body, "Stephen King")
  end

  test "create with prefix true matches partial words" do
    post("/#{@catalog.slug}/en/search/simple", :params => { :q => "kin", :prefix => "true" })

    follow_redirect!
    assert_response(:success)
    assert_includes(@response.body, "Stephen King")
  end

  test "create with prefix false requires an exact stem match" do
    post("/#{@catalog.slug}/en/search/simple", :params => { :q => "kin", :prefix => "false" })

    follow_redirect!
    assert_response(:success)
    refute_includes(@response.body, "Stephen King")
  end

  test "show reuses the prefix stored on the saved search" do
    post("/#{@catalog.slug}/en/search/simple", :params => { :q => "kin", :prefix => "false" })
    saved_search = SimpleSearch.order(:created_at).last

    get("/#{@catalog.slug}/en/search/simple/#{saved_search.uuid}")

    assert_response(:success)
    refute_includes(@response.body, "Stephen King")
  end
end
