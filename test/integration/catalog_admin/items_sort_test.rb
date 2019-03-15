require "test_helper"

class CatalogAdmin::ItemsSortTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "the authors are sort by age" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors")
    click_on('Sorted by Name')
    click_on('Age')

    assert_equal("Very Young", find(:xpath, "//table/tbody/tr[1]/td[1]").text)
    assert_equal("Young apprentice", find(:xpath, "//table/tbody/tr[2]/td[1]").text)
    assert_equal("Stephen King", find(:xpath, "//table/tbody/tr[3]/td[1]").text)
    assert_equal("Very Old", find(:xpath, "//table/tbody/tr[4]/td[1]").text)
  end

  test "the authors are sort by rank" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors")
    click_on('Sorted by Name')
    click_on('Rank')

    assert_equal("Stephen King", find(:xpath, "//table/tbody/tr[1]/td[1]").text)
    assert_equal("Very Old", find(:xpath, "//table/tbody/tr[2]/td[1]").text)
  end

  test "the authors are sort by born" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors")
    click_on('Sorted by Name')
    click_on('Born')

    assert_equal("Stephen King", find(:xpath, "//table/tbody/tr[1]/td[1]").text)
    assert_equal("Very Old", find(:xpath, "//table/tbody/tr[2]/td[1]").text)
  end
end
