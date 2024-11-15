require 'test_helper'

class CatalogAdmin::ItemTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @one_author = item_types(:one_author)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_controller_geofields_json_response
    get catalog_admin_item_type_geofields_url(
      @one_author.catalog,
      locale: 'en',
      item_types_id: @one_author.id
    ), xhr: true

    assert_response :success
    assert_equal "application/json", @response.media_type

    json_response = response.parsed_body
    assert json_response.is_a?(Array)
    json_response.each do |item|
      assert %w[Birthplace Home].include?(item[:name])
    end
  end
end
