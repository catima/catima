class Admin::DashboardController < Admin::BaseController
  def index
    authorize(Catalog, :index?)
  end
end
