require "test_helper"

class CatalogAdmin::FieldsRestrictedTest < ActionDispatch::IntegrationTest
  test "restricted fields are visible for catalog staff" do
    # Catalog staff roles are editors, super-editors, reviewers and admins
    log_in_as("one-editor@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    assert(page.has_content?("Created by one-admin@example.com"))
    logout

    log_in_as("one-super-editor@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    assert(page.has_content?("Created by one-admin@example.com"))
    logout

    log_in_as("one-reviewer@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    assert(page.has_content?("Created by one-admin@example.com"))
    logout

    log_in_as("one-admin@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    assert(page.has_content?("Created by one-admin@example.com"))
  end

  test "restricted fields are not visible for guests, users and members" do
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    refute(page.has_content?("Created by one-admin@example.com"))

    log_in_as("two-user@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    refute(page.has_content?("Created by one-admin@example.com"))
    logout

    log_in_as("one-member@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    refute(page.has_content?("Created by one-admin@example.com"))
  end
end
