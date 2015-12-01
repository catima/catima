# Encapsulates the review process for a catalog that doesn't require review.
# That is to say: do nothing.
#
class Review::Noop
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def pending_submission?
    false
  end

  def approved?
    false
  end

  def rejected?
    false
  end

  # TODO: test
  def pending?
  end

  def approved(*)
  end

  def rejected(*)
  end

  def submitted
    # pass
  end
end
