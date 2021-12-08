require "test_helper"

class CatalogAdmin::FieldsTest < ActionDispatch::IntegrationTest
  test "add a multilingual text field" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin/authors/fields")
    click_on("Text field")

    fill_in("field[name_de]", :with => "Geburtsort")
    fill_in("field[name_plural_de]", :with => "Geburtsorte")
    fill_in("field[name_en]", :with => "Birthplace")
    fill_in("field[name_plural_en]", :with => "Birthplaces")
    fill_in("field[name_fr]", :with => "Lieu de naissance")
    fill_in("field[name_plural_fr]", :with => "Lieux de naissance")
    fill_in("field[name_it]", :with => "Luogo di nascita")
    fill_in("field[name_plural_it]", :with => "Luoghi di nascita")

    fill_in("Slug (singular)", :with => "birthplace")
    check("Use this as the primary field")
    check("Enable the multilingual option")
    select("Single value – required", :from => "field[style]")
    fill_in("Minimum length (optional)", :with => 3)
    fill_in("Maximum length (optional)", :with => 50)

    assert_difference("item_types(:multilingual_author).fields.count") do
      click_on("Create field")
    end

    field = item_types(:multilingual_author).fields.where(:slug => "birthplace").first!
    assert_equal(3, field.minimum.to_i)
    assert_equal(50, field.maximum.to_i)
    assert_equal("Birthplace", field.name)
    assert_equal("Birthplaces", field.name_plural)
    assert(field.display_in_list?)
    assert(field.primary?)
    assert(field.required?)
    assert(field.i18n?)
    refute(field.multiple?)
  end

  test "add an int field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Integer field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
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
    visit("/two/en/admin/authors/fields")
    click_on("Decimal field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
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
    visit("/two/en/admin/authors/fields")
    click_on("Email field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a URL field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("URL field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a file field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("File field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    fill_in("Types", :with => "jpg png gif")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a reference field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Reference field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("Two", :from => "Reference")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a choice set field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Choice set field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("Languages", :from => "Choice set")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a compound field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Compound field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    first('input#field_template', visible: false).set('{"en":"{{test}}"}')
    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a embed url field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Embed field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("url", :from => "Format")

    fill_in("Iframe width", :with => 360)
    fill_in("Iframe height", :with => 360)

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "add a embed iframe field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Embed field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    select("iframe", :from => "Format")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end

  test "edit a field" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/authors/fields")
    first("a.field-action-edit").click
    fill_in("field[name_en]", :with => "Changed!")
    fill_in("Slug", :with => "changed")

    assert_no_difference("Field.count") do
      click_on("Save field")
    end

    field = item_types(:one_author).fields.where(:slug => "changed").first!
    assert_equal("Changed!", field.name)
  end

  test "delete a field" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/authors/fields")

    assert_difference("item_types(:one_author).fields.count", -1) do
      first("a.field-action-delete").click
    end
  end
end
