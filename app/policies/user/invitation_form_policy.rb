class User::InvitationFormPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    user.system_admin? || user.admin_of_any_catalog?
  end
  alias_method :new?, :create?

  def permit(params)
    allowed = [
      :email,
      :primary_language,
      { :catalog_permissions_attributes => [:id, :catalog_id, :role] }
    ]
    prohibit_admin_role(params.permit(*allowed))
  end

  private

  def prohibit_admin_role(params)
    params.fetch(:catalog_permissions_attributes, {}).delete_if do |_, perm|
      perm[:role] == "admin"
    end
    params
  end
end
