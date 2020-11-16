require "test_helper"

class DatabaseTemplateTest < ActionDispatch::IntegrationTest
  test "shows custom home page database template" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    tpl = template_storages(:erb_template)
    tpl.path = 'home/index'
    tpl.save!

    visit("/")
    assert(page.has_content?(/My custom page/i))
    tpl.path = 'home/index2'
    tpl.save!
  end
end
