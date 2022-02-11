require "test_helper"

class CatalogAdmin::FieldsPrimaryTest < ActionDispatch::IntegrationTest
  test "can select field as primary" do
    log_in_as("one-admin@example.com", "password")

    # Datetime
    visit("/one/en/admin/authors/fields/born/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Choice-set
    visit("/one/en/admin/authors/fields/language/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Reference
    visit("/one/en/admin/authors/fields/collaborator/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Decimal
    visit("/one/en/admin/authors/fields/rank/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Email
    visit("/one/en/admin/authors/fields/email/edit")
    assert(page.has_content?("Use this as the primary field"))

    # URL
    visit("/one/en/admin/authors/fields/site/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Int
    visit("/one/en/admin/authors/fields/age/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Bool
    visit("/one/en/admin/authors/fields/deceased/edit")
    assert(page.has_content?("Use this as the primary field"))

    # Text
    visit("/one/en/admin/authors/fields/nickname/edit")
    assert(page.has_content?("Use this as the primary field"))
  end

  test "cannot select field as primary" do
    log_in_as("one-admin@example.com", "password")

    # File
    visit("/one/en/admin/authors/fields/bio/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Geometry
    visit("/one/en/admin/authors/fields/birthplace/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Image
    visit("/one/en/admin/authors/fields/picture/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Formatted text
    visit("/one/en/admin/books/fields/notes/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Compound
    visit("/one/en/admin/authors/fields/compound/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Embed
    visit("/one/en/admin/authors/fields/media/edit")
    refute(page.has_content?("Use this as the primary field"))

    # Editor (Restricted field)
    visit("/one/en/admin/authors/fields/editor/edit")
    refute(page.has_content?("Use this as the primary field"))
  end
end
