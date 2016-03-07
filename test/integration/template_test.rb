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
  end

  test "shows custom liquid template for home page" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    tpl = template_storages(:liquid_template)
    tpl.path = 'home/index'
    tpl.save!

    visit("/")
    assert(page.has_content?(/Hello WORLD has 5 letters!/i))
  end
end

