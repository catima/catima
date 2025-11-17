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

  def test_image_alt_presents
    item = items(:one_author_with_images)

    get "/#{item.catalog.slug}/en/#{item.item_type.slug}"
    assert_response :success
    assert_includes @response.body, "alt=\"One author picture\""
  end

  def test_browse_field_finds_category_choice_set_field
    # Test that browsing by a ChoiceSet field inside a category works
    red_choice = choices(:nested_car_color_red)
    vehicle_type = item_types(:nested_vehicle)

    # Browse by the car color field (which is inside the nested_car category)
    get "/#{vehicle_type.catalog.slug}/en/#{vehicle_type.slug}?color=#{red_choice.id}"
    assert_response :success

    # Should show only red cars
    assert_includes @response.body, "Red Toyota"
    assert_includes @response.body, "Red Mazda"
    assert_not_includes @response.body, "Blue Honda"
    assert_not_includes @response.body, "Mountain Bike"
  end

  def test_browse_field_finds_category_complex_datation_field
    # Test that browsing by a ComplexDatation field inside a category works
    year_2020 = choices(:nested_car_year_2020)
    vehicle_type = item_types(:nested_vehicle)

    # Browse by the manufacture date field (which is inside the nested_car category)
    get "/#{vehicle_type.catalog.slug}/en/#{vehicle_type.slug}?manufacture-date=#{year_2020.id}"
    assert_response :success

    # Should show only 2020 cars
    assert_includes @response.body, "Red Toyota"
    assert_includes @response.body, "Red Mazda"
    assert_not_includes @response.body, "Blue Honda"
    assert_not_includes @response.body, "Mountain Bike"
  end
end
