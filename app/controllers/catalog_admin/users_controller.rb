class CatalogAdmin::UsersController < CatalogAdmin::BaseController
  layout "catalog_admin/setup", :only => :index

  def index
    authorize(User)
    @users = policy_scope(User).sorted
  end
end
