require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "#pending_submission?" do
    assert(item_review(:review_status => "not-ready").pending_submission?)
    assert(item_review(:review_status => "rejected").pending_submission?)
    refute(item_review(:review_status => "ready").pending_submission?)
    refute(item_review(:review_status => "approved").pending_submission?)
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

    refute(review.pending_submission?)
    assert("ready", review.item.review_status)
  end

  private

  def item_review(attrs={})
    Review.new(Item.new(attrs))
  end
end
