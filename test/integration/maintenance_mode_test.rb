require 'test_helper'

class MaintenanceModeTest < ActionDispatch::IntegrationTest
  teardown do
    ENV['MAINTENANCE_MODE'] = '0'
    ENV.delete('MAINTAINER_IPS')
  end

  test "does not redirect to maintenance page if mode is disabled" do
    get root_path
    assert_response :success
  end

  test "redirects to maintenance page if mode is enabled" do
    ENV['MAINTENANCE_MODE'] = '1'
    get root_path
    assert_redirected_to maintenance_path
    follow_redirect!
    assert_response :service_unavailable
  end

  test "does not redirect to maintenance page if mode is enabled and IP is whitelisted" do
    ENV['MAINTENANCE_MODE'] = '1'
    ENV['MAINTAINER_IPS'] = '127.0.0.1'
    get root_path
    assert_response :success
  end

  test "redirects away from maintenance page when mode is disabled" do
    get maintenance_path
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "redirects away from maintenance page when mode is enabled and IP is whitelisted" do
    ENV['MAINTENANCE_MODE'] = '1'
    ENV['MAINTAINER_IPS'] = '127.0.0.1'
    get maintenance_path
    assert(page.has_content?("Catalogues disponibles"))
  end

  test "redirects back to requested page when mode is disabled" do
    ENV['MAINTENANCE_MODE'] = '1'
    get root_path
    assert_redirected_to maintenance_path
    ENV['MAINTENANCE_MODE'] = '0'
    get maintenance_path
    assert(page.has_content?("Catalogues disponibles"))
  end
end
