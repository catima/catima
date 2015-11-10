# Note that this policy is only for *management* of Pages. All users can
# of course view pages, since they are public.
class PagePolicy
  attr_reader :user, :page
  delegate :catalog, :to => :page

  def initialize(user, page)
    @user = user
    @page = page
  end

  def index?
    user.system_admin? || user.editor_of_any_catalog?
  end

  def create?
    role_at_least?("editor")
  end
  alias_method :new?, :create?
  alias_method :show?, :create?

  def update?
    role_at_least?(owned_page? ? "editor" : "reviewer")
  end
  alias_method :edit?, :update?
  alias_method :destroy?, :update?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.system_admin?
      Page.where(:catalog_id => user.editor_catalog_ids).merge(scope.all)
    end
  end

  private

  def role_at_least?(role)
    user.system_admin? || user.catalog_role_at_least?(catalog, role)
  end

  def owned_page?
    page.creator == user
  end
end
