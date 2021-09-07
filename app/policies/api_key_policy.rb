class APIKeyPolicy
  attr_reader :user, :api_key

  def initialize(user, api_key)
    @user = user
    @api_key = api_key
  end

  def user_is_system_admin?
    user.system_admin?
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(api_key.catalog, "admin")
  end

  alias_method :update?, :user_is_catalog_admin?
  alias_method :destroy?, :user_is_catalog_admin?
end
