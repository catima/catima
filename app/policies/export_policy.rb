class ExportPolicy
  attr_reader :user, :export
  delegate :catalog, :to => :export

  def initialize(user, export)
    @user = user
    @export = export
  end

  def index?
    create?
  end

  def create?
    return false unless user.authenticated?
    return true if user.system_admin?
    user.catalog_role_at_least?(catalog, "admin")
  end

  def download?
    return false unless export.validity?
    return false unless export.ready?
    return false unless export.file?
    create?
  end
end
