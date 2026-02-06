class MessagePolicy
  attr_reader :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

  def index?
    user&.system_admin?
  end

  def create?
    user&.system_admin?
  end

  def edit?
    update?
  end

  def update?
    user&.system_admin?
  end

  def destroy?
    user&.system_admin?
  end
end
