class User::AdminInvitationFormPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    user.system_admin?
  end
  alias_method :new?, :create?
end
