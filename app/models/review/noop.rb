# Encapsulates the review process for a catalog that doesn't require review.
# That is to say: do nothing.
#
class Review::Noop
  def pending_submission?
    false
  end

  def approved?
    false
  end

  def rejected?
    false
  end

  def approved(*)
  end

  def rejected(*)
  end

  def submitted
    # pass
  end
end
