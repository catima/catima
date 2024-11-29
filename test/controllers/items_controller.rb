require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @item = items(:two)
    @item_not_indexable = items(:search_vehicle_toyota_highlander)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_meta_description_presents
    # In the item type.
    get "/#{@item.catalog.slug}/en/#{@item.item_type.slug}"
    assert_response :success
    assert_includes @response.body, "<meta name=\"description\" content=\"two - Twos\">"

    # In the item.
    get "/#{@item.catalog.slug}/en/#{@item.item_type.slug}/#{@item.id}"
    assert_response :success
    assert_includes @response.body, "<meta name=\"description\" content=\"two - 298486374\">"
  end

  def test_meta_robot_presents_if_not_indexable_seo
    # In the item type.
    get "/#{@item_not_indexable.catalog.slug}/en/#{@item_not_indexable.item_type.slug}"
    assert_response :success
    assert_includes @response.body, "<meta name=\"robots\" content=\"noindex, nofollow\">"

    # In the item.
    get "/#{@item_not_indexable.catalog.slug}/en/#{@item_not_indexable.item_type.slug}/#{@item_not_indexable.id}"
    assert_response :success
    assert_includes @response.body, "<meta name=\"robots\" content=\"noindex, nofollow\">"

    # In item for item type still indexable.
    get "/#{@item.catalog.slug}/en/#{@item.item_type.slug}/#{@item.id}"
    assert_response :success
    assert_not_includes @response.body, "<meta name=\"robots\" content=\"noindex, nofollow\">"
  end
end
