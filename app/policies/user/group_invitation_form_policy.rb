class User::GroupInvitationFormPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    @user.catalog_role_at_least? @record.group.catalog, 'admin'
  end
end
