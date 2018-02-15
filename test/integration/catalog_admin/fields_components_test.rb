require "test_helper"

class CatalogAdmin::FieldsComponentsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "rendering of formatted text component" do
    log_in_as('one-admin@example.com', 'password')

    book = items(:one_book_end_of_watch)
    visit("/one/en/admin/books/#{book.to_param}/edit")

    assert(page.has_selector?('div.ql-editor'))
    find('div.ql-editor').base.send_keys('Hello world')
    click_on('Save Book')

    b = book.reload
    c = JSON.parse(b.data['one_book_notes_uuid'])
    assert_equal(c["content"], '<p>Hello world</p>')
  end
end
