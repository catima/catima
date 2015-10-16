require "test_helper"

class CatalogAdmin::FieldsTest < ActionDispatch::IntegrationTest
  test "add a text field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Text field")
    fill_in("Name", :with => "Birthplace")
    fill_in("Name (plural)", :with => "Birthplaces")
    fill_in("Slug (singular)", :with => "birthplace")
    check("Use this as the primary field for Authors")
    select("Single value – required", :from => "field[style]")
    fill_in("Minimum length (optional)", :with => 3)
    fill_in("Maximum length (optional)", :with => 50)

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end

    field = item_types(:two_author).fields.where(:slug => "birthplace").first!
    assert_equal(3, field.minimum.to_i)
    assert_equal(50, field.maximum.to_i)
    assert_equal("Birthplace", field.name)
    assert_equal("Birthplaces", field.name_plural)
    assert(field.display_in_list?)
    assert(field.primary?)
    assert(field.required?)
    refute(field.multiple?)
  end

  test "add an int field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Int field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    fill_in("Minimum value (optional)", :with => 3)
    fill_in("Maximum value (optional)", :with => 50)

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end

    field = item_types(:two_author).fields.where(:slug => "test").first!
    assert_equal(3, field.minimum.to_i)
    assert_equal(50, field.maximum.to_i)
  end

  test "add a decimal field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Decimal field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    fill_in("Minimum value (optional)", :with => "1.25")
    fill_in("Maximum value (optional)", :with => "8.75")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end

    field = item_types(:two_author).fields.where(:slug => "test").first!
    assert_equal("1.25", field.minimum)
    assert_equal("8.75", field.maximum)
  end

  test "add an email field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Email field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a URL field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("URL field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a file field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("File field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    fill_in("Types", :with => "jpg png gif")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a reference field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Reference field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("Two", :from => "Reference")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a choice set field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Choice set field")
    fill_in("Name", :with => "Test")
    fill_in("Name (plural)", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("Languages", :from => "Choice set")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end
end
