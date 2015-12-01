require "test_helper"
require_relative "./approvals_test"

class CatalogAdmin::ApprovalsAjaxTest < CatalogAdmin::ApprovalsTest
  setup { use_javascript_capybara_driver }
end
