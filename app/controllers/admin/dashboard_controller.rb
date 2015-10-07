class Admin::DashboardController < Admin::BaseController
  def index
    authorize(Catalog, :index?)
    authorize(User, :index?)

    @users = policy_scope(User).sorted
    @catalogs = policy_scope(Catalog).sorted
  end
end
