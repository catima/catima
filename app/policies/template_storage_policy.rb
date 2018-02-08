class TemplateStoragePolicy
  attr_reader :user, :template_storage

  def initialize(user, template_storage)
    @user = user
    @template_storage = template_storage
  end

  def user_is_system_admin?
    user.system_admin?
  end
  alias_method :create?, :user_is_system_admin?
  alias_method :edit?, :user_is_system_admin?
  alias_method :index?, :user_is_system_admin?
  alias_method :new?, :user_is_system_admin?
  alias_method :update?, :user_is_system_admin?
  alias_method :show?, :user_is_system_admin?
  alias_method :destroy?, :user_is_system_admin?
end
