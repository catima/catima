require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::ControllerHelpers

  def setup
    @page = pages(:line_one)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_show_line
    get(:show, params: { catalog_slug: @page.catalog.slug, locale: 'en', slug: @page.slug })
    assert_response :success
  end
end
