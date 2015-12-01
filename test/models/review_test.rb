require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test ".public_items_in_catalog" do
    items = catalogs(:reviewed).public_items.to_a
    assert_includes(items, items(:reviewed_book_finders_keepers_approved))
    refute_includes(items, items(:reviewed_book_end_of_watch))
  end

  test "#submit_allowed?" do
    assert(item_review(:review_status => "not-ready").submit_allowed?)
    assert(item_review(:review_status => "rejected").submit_allowed?)
    refute(item_review(:review_status => "ready").submit_allowed?)
    refute(item_review(:review_status => "approved").submit_allowed?)
  end

  test "#approved?" do
    refute(item_review(:review_status => "not-ready").approved?)
    refute(item_review(:review_status => "rejected").approved?)
    refute(item_review(:review_status => "ready").approved?)
    assert(item_review(:review_status => "approved").approved?)
  end

  test "#rejected?" do
    refute(item_review(:review_status => "not-ready").rejected?)
    assert(item_review(:review_status => "rejected").rejected?)
    refute(item_review(:review_status => "ready").rejected?)
    refute(item_review(:review_status => "approved").rejected?)
  end

  test "#approved" do
    review = item_review(:review_status => "ready")
    review.approved(:by => users(:one_reviewer))

    assert(review.approved?)
    assert_equal(users(:one_reviewer), review.item.reviewer)
  end

  test "#rejected" do
    review = item_review(:review_status => "ready")
    review.rejected(:by => users(:one_reviewer))

    assert(review.rejected?)
    assert_equal(users(:one_reviewer), review.item.reviewer)
  end

  test "#submitted" do
    review = item_review(:review_status => "not-ready")
    review.submitted

    refute(review.submit_allowed?)
    assert("ready", review.item.review_status)
  end

  private

  def item_review(attrs={})
    Review.new(Item.new(attrs))
  end
end
