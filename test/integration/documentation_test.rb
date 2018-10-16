require "test_helper"

class DocumentationTest < ActionDispatch::IntegrationTest
  include WithVCR

  test "admin should see everything" do
    log_in_as("multilingual-admin@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/fr/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Search"))
    assert(page.has_content?("Favorites & groups"))
    assert(page.has_content?("Catalog edition"))
    assert(page.has_content?("Catalog admin"))
  end

  test "editor should see everything except admin section" do
    log_in_as("multilingual-editor@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/fr/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Search"))
    assert(page.has_content?("Favorites & groups"))
    assert(page.has_content?("Catalog edition"))
    refute(page.has_content?("Catalog admin"))
  end

  test "member should see everything except editor & admin sections" do
    log_in_as("multilingual-member@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/fr/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Search"))
    assert(page.has_content?("Favorites & groups"))
    refute(page.has_content?("Catalog edition"))
    refute(page.has_content?("Catalog admin"))
  end

  test "user should see everything except editor & admin sections" do
    log_in_as("multilingual-user@example.com", "password")

    with_vcr_cassette do
      visit("/multilingual/fr/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Search"))
    assert(page.has_content?("Favorites & groups"))
    refute(page.has_content?("Catalog edition"))
    refute(page.has_content?("Catalog admin"))
  end

  test "guest should see only introduction & first section" do
    with_vcr_cassette do
      visit("/multilingual/fr/doc")
    end

    assert(page.has_content?("Documentation"))

    assert(page.has_content?("Search"))
    refute(page.has_content?("Favorites & groups"))
    refute(page.has_content?("Catalog edition"))
    refute(page.has_content?("Catalog admin"))
  end
end
