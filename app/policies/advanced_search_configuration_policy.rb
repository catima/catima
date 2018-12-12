class AdvancedSearchConfigurationPolicy
  attr_reader :user, :advanced_search_configuration
  delegate :catalog, :to => :advanced_search_configuration

  def initialize(user, advanced_search_configuration)
    @user = user
    @advanced_search_configuration = advanced_search_configuration
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(catalog, "admin")
  end

  alias_method :index?, :user_is_catalog_admin?
  alias_method :new?, :user_is_catalog_admin?
  alias_method :create?, :user_is_catalog_admin?
  alias_method :show?, :user_is_catalog_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :update?, :user_is_catalog_admin?
  alias_method :destroy?, :user_is_catalog_admin?
end
