class ExportPolicy
  attr_reader :user, :export
  delegate :catalog, :to => :export

  def initialize(user, export)
    @user = user
    @export = export
  end

  def index?
    user_check
  end

  def create?
    return false unless user.authenticated?
    return true if user.system_admin?
    # Only system admins can create sql & csv exports
    return false unless @export.category.eql? "catima"

    user.catalog_role_at_least?(catalog, "admin")
  end

  def download?
    return false unless export.validity?
    return false unless export.ready?
    return false unless export.file?

    user_check
  end

  def user_check
    return false unless user.authenticated?
    return true if user.system_admin?

    user.catalog_role_at_least?(catalog, "admin")
  end
end
