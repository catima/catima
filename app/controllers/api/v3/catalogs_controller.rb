class API::V3::CatalogsController < API::V3::BaseController
  before_action :find_catalogs
  before_action :log_request

  after_action -> { set_pagination_header(:catalogs) }

  def index
    @catalogs = @catalogs.page(params[:page] || 1).per(params[:per] || 25)
  end

  private

  def log_request
    APILog.create(
      user: @current_user,
      endpoint: request.fullpath,
      remote_ip: request.remote_ip,
      payload: params
    )
  end

  def find_catalogs
    ids = @current_user.public_and_accessible_catalogs.pluck(:id)
    @catalogs = Catalog.where(id: ids.uniq)
  end
end
