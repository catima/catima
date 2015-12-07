# Base class of ItemTypePolicy and CategoryPolicy.
class FieldSetPolicy
  attr_reader :user, :field_set
  delegate :catalog, :to => :field_set

  def initialize(user, field_set)
    @user = user
    @field_set = field_set
  end

  def index?
    user.system_admin? || user.admin_of_any_catalog?
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(catalog, "admin")
  end
  alias_method :create?, :user_is_catalog_admin?
  alias_method :destroy?, :user_is_catalog_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :new?, :user_is_catalog_admin?
  alias_method :show?, :user_is_catalog_admin?
  alias_method :update?, :user_is_catalog_admin?
end
