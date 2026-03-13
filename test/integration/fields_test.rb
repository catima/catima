require "test_helper"

class FieldsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }
  include ItemReferenceHelper

  test "view item with editor" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
    end
  end

  test "view item with editor and updater" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?('Updated by'))
    end
  end

  test "view item with editor and timestamps" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?(Time.current.year.to_s))
    end
  end

  test "view item with editor, updater and timestamps" do
    book = items(:one_book_theory_of_relativity)
    visit("/one/en/other-books/#{book.to_param}")

    within("body>.container") do
      assert(page.has_content?(book.creator.email))
      assert(page.has_content?('Updated by'))
      assert(page.has_content?(Time.current.year.to_s))
    end
  end

  test "view item with deleted editor" do
    visit("/one/en/other-books/#{items(:one_book_mister_nobody).to_param}")

    within("body>.container") do
      assert(page.has_content?(users(:one_user_deleted).email))
    end
  end
end
