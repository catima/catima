require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get sysadmin" do
    get :sysadmin
    assert_response :success
  end

end
