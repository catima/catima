require "test_helper"

class CatalogAdmin::ApprovalsTest < ActionDispatch::IntegrationTest
  test "approval controls aren't shown if not in review" do
    log_in_as("reviewed-reviewer@example.com", "password")
    visit_draft_item
    refute(page.has_content?(/awaiting your review/i))
  end

  test "approve an item that is in review" do
    log_in_as("reviewed-reviewer@example.com", "password")
    visit_in_pending_item
    assert(page.has_content?(/awaiting your review/i))
    click_on("Approve")
    assert(page.has_content?(/this book is approved/i))
  end

  test "reject an item that is in review" do
    log_in_as("reviewed-reviewer@example.com", "password")
    visit_in_pending_item
    assert(page.has_content?(/awaiting your review/i))
    click_on("Reject")
    assert(page.has_content?(/this book was rejected/i))
  end

  private

  def visit_draft_item
    book = items(:reviewed_book_end_of_watch)
    visit("/reviewed/en/admin/books/#{book.to_param}/edit")
  end

  def visit_in_pending_item
    book = items(:reviewed_book_harry_potter_pending)
    visit("/reviewed/en/admin/books/#{book.to_param}/edit")
  end
end
