require "test_helper"

class FavoritesTest < ActionDispatch::IntegrationTest  
  test "redirected to login with unauthenticated user" do
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")
    click_on("Add to favorites")
    assert(page.has_content?("Log in"))
  end

  test "add item to favorites with authenticated user" do
    log_in_as("one@example.com", "password")
    author = items(:one_author_very_old)
    visit("/one/en/authors/#{author.to_param}")
    click_on("Add to favorites")
    assert(page.has_content?("Remove from favorites"))
  end

  test "remove item from favorites with authenticated user" do
    log_in_as("one@example.com", "password")
    author = items(:one_author_stephen_king)
    visit("/one/en/authors/#{author.to_param}")
    click_on("Remove from favorites")
    assert(page.has_content?("Add to favorites"))
  end

  test "add item to favorites with authenticated user in private catalog" do
    log_in_as("one-admin@example.com", "password")
    book = items(:not_visible_book_farewell_to_arms)
    visit("/not-visible/en/not-visible-books/#{book.to_param}")
    click_on("Add to favorites")
    assert(page.has_content?("Remove from favorites"))
  end

  test "remove item from favorites with authenticated user in private catalog" do
    log_in_as("one-editor@example.com", "password")
    book = items(:not_visible_book_farewell_to_arms)
    visit("/not-visible/en/not-visible-books/#{book.to_param}")
    click_on("Remove from favorites")
    assert(page.has_content?("Add to favorites"))
  end

  test "list favorites for authenticated user" do
    log_in_as("one@example.com", "password")
    visit("/en/favorites")
    assert(page.has_content?("Stephen King"))
    refute(page.has_content?("A Farewell to Arms"))
  end

  test "list empty favorites for authenticated user" do
    log_in_as("one-reviewer@example.com", "password")
    visit("/en/favorites")
    assert(page.has_content?("You don't have favorites yet!"))
  end

  test "list favorites for unauthenticated user" do
    visit("/en/favorites")
    assert(page.has_content?("Log in"))
  end
end
