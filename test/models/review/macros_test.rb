require "test_helper"

class Review::MacrosTest < ActiveSupport::TestCase
  subject { Item.new }

  should \
    validate_inclusion_of(:review_status)
    .in_array(%w(not-ready ready rejected approved))

  should_not allow_value(nil).for(:review_status)

  test "submits for review when checked" do
    item = items(:reviewed_book_end_of_watch)
    item.update(:submit_for_review => "1")
    assert("ready", item.review_status)
  end

  test "does not submit for review otherwise" do
    item = items(:reviewed_book_end_of_watch)
    item.update(:submit_for_review => "0")
    assert("not-ready", item.review_status)
  end

  test "#review for catalog that requires review" do
    review = items(:reviewed_book_end_of_watch).review
    assert_instance_of(Review, review)
    assert_equal(items(:reviewed_book_end_of_watch), review.item)
  end

  test "#review for catalog that does not require review" do
    review = items(:one_author_stephen_king).review
    assert_instance_of(Review::Noop, review)
  end
end
