require "test_helper"

class CatalogAdmin::FieldsComponentsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "rendering of formatted text component" do
    log_in_as('one-admin@example.com', 'password')

    book = items(:one_book_end_of_watch)
    visit("/one/en/admin/books/#{book.to_param}/edit")

    sleep 2

    assert(page.has_selector?('div.ql-editor'))
    find('div.ql-editor').base.send_keys(' and interesting')
    within('#item_one_book_author_uuid_json-editor') do
      find(".css-g1d714-ValueContainer").click # Click on the filter input
      sleep(2)

      within(".css-4ljt47-MenuList") do # Within the filter list
        find('div', text: 'Very Old', match: :first, visible: false).click
      end
    end

    click_on('Save Book')

    b = book.reload
    c = JSON.parse(b.data['one_book_notes_uuid'])
    assert_equal(c["content"], "<p style=\"display:none;\"></p><p>Very good book and interesting</p><p style=\"display:none;\"></p>")
  end

  test "multilingual required formatted text component shows error message" do
    log_in_as('multilingual-admin@example.com', 'password')

    visit("/multilingual/en/admin/books/new")
    click_on('Create Book')

    page.has_content?("<td colspan=\"2\">can't be blank</td>")
  end
end
