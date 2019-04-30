# Note that this policy is only for *management* of ChoiceSets. All users can
# of course view choices, since they are all public.
class ChoiceSetPolicy
  attr_reader :user, :choice_set
  delegate :catalog, :to => :choice_set

  def initialize(user, choice_set)
    @user = user
    @choice_set = choice_set
  end

  def index?
    user.system_admin? || user.admin_of_any_catalog?
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(catalog, "admin")
  end
  alias_method :create?, :user_is_catalog_admin?

  def create_choice?
    user.system_admin? || user.catalog_role_at_least?(catalog, "editor")
  end

  alias_method :destroy?, :user_is_catalog_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :new?, :user_is_catalog_admin?
  alias_method :show?, :user_is_catalog_admin?
  alias_method :update?, :user_is_catalog_admin?
  alias_method :update_synonyms?, :create_choice?
end
