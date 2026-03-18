require 'test_helper'

class CatalogAdmin::ContainersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @container = containers(:one_line_container)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_edit_line
    get edit_catalog_admin_container_url(@container,
                                         catalog_slug: @container.page.catalog.slug, locale: 'en')
    assert_response :success
  end
end
