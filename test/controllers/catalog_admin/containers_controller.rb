require 'test_helper'

class CatalogAdmin::ContainersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    @container = containers(:one_line_container)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_edit_line
    get(:edit, params: { catalog_slug: @container.page.catalog.slug, locale: 'en', id: @container.id })
    assert_response :success
  end
end
