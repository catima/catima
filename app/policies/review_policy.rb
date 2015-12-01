class ReviewPolicy
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def user_is_reviewer?
    user.system_admin? || user.catalog_role_at_least?(catalog, "reviewer")
  end
  alias_method :approve?, :user_is_reviewer?
  alias_method :reject?, :user_is_reviewer?

  private

  def catalog
    review.item.catalog
  end
end
