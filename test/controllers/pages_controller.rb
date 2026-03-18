require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @page = pages(:line_one)
    @user = users(:one_admin)
    sign_in(@user)
  end

  def test_show_line
    get "/#{@page.catalog.slug}/en/#{@page.slug}"
    assert_response :success
  end
end
