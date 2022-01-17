# Note that this policy is only for *management* of Items. All users can
# of course view items, since they are public.
class SuggestionPolicy
  attr_reader :user, :suggestion

  delegate :catalog, :to => :suggestion

  def initialize(user, suggestion)
    @user = user
    @suggestion = suggestion
  end

  def destroy?
    user.system_admin? || role_at_least?("editor")
  end

  alias_method :update_processed?, :destroy?

  private

  def role_at_least?(role)
    user.system_admin? || user.catalog_role_at_least?(catalog, role)
  end
end
