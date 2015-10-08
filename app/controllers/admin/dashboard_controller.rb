class Admin::DashboardController < Admin::BaseController
  def index
    authorize(Catalog, :index?)
    authorize(User, :index?)

    @users = User.sorted
    @catalogs = Catalog.sorted
  end
end
