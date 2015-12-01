require "test_helper"

class Review::NoopTest < ActiveSupport::TestCase
  test "#pending_submission?" do
    refute(review.pending_submission?)
  end

  test "#approved?" do
    refute(review.approved?)
  end

  test "#rejected?" do
    refute(review.rejected?)
  end

  test "#approved" do
    review.approved(:by => nil)
  end

  test "#rejected" do
    review.rejected(:by => nil)
  end

  test "#submitted" do
    review.submitted
  end

  private

  def review
    Review::Noop.new(Item.new)
  end
end
