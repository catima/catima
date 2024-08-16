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
    assert_nothing_raised do
      review.approved(:by => nil)
    end
  end

  test "#rejected" do
    assert_nothing_raised do
      review.rejected(:by => nil)
    end
  end

  test "#submitted" do
    assert_nothing_raised do
      review.submitted
    end
  end

  private

  def review
    Review::Noop.new(Item.new)
  end
end
