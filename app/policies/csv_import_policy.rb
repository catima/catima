class CSVImportPolicy
  attr_reader :user, :csv_import

  delegate :catalog, :to => :csv_import

  def initialize(user, csv_import)
    @user = user
    @csv_import = csv_import
  end

  def create?
    role_at_least?("editor")
  end
  alias_method :new?, :create?

  private

  # TODO: DRY up with ItemPolicy
  def role_at_least?(role)
    user.system_admin? || user.catalog_role_at_least?(catalog, role)
  end
end
