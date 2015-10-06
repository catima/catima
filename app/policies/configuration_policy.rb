class ConfigurationPolicy
  attr_reader :user

  def initialize(user, _configuration)
    @user = user
  end

  def update?
    user.system_admin?
  end
end
