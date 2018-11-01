require "test_helper"

class DocumentationTest < ActionDispatch::IntegrationTest
  include WithVCR

  test "admin should see everything" do
    log_in_as("multilingual-admin@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/en/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Catalog visitor"))
    assert(page.has_content?("Catalog user"))
    assert(page.has_content?("Catalog editor"))
    assert(page.has_content?("Catalog administrator"))
  end

  test "editor should see everything except admin section" do
    log_in_as("multilingual-editor@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/en/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Catalog visitor"))
    assert(page.has_content?("Catalog user"))
    assert(page.has_content?("Catalog editor"))
    refute(page.has_content?("Catalog administrator"))
  end

  test "member should see everything except editor & admin sections" do
    log_in_as("multilingual-member@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/en/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Catalog visitor"))
    assert(page.has_content?("Catalog user"))
    refute(page.has_content?("Catalog editor"))
    refute(page.has_content?("Catalog administrator"))
  end

  test "user should see everything except editor & admin sections" do
    log_in_as("multilingual-user@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/en/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Catalog visitor"))
    assert(page.has_content?("Catalog user"))
    refute(page.has_content?("Catalog editor"))
    refute(page.has_content?("Catalog administrator"))
  end

  test "guest should see only introduction & first section" do
    with_vcr_cassette do
      visit("/multilingual/en/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Catalog visitor"))
    refute(page.has_content?("Catalog user"))
    refute(page.has_content?("Catalog editor"))
    refute(page.has_content?("Catalog administrator"))
  end
end
