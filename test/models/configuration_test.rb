require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  should validate_presence_of(:root_mode)
  should validate_inclusion_of(:root_mode).in_array(%w(listing custom redirect))

  test "doesn't allow 'redirect' if there aren't active catalogs" do
    Catalog.active.update_all(:deactivated_at => Time.current)
    config = Configuration.first!
    config.root_mode = "redirect"
    refute(config.valid?)
  end
end
