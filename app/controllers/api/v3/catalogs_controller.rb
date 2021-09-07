class API::V3::CatalogsController < API::V3::BaseController
  DEFAULT_PAGE_SIZE = 25
  MAX_PAGE_SIZE = 100

  before_action :set_pagination_params
  before_action :find_catalogs
  before_action :log_request

  after_action -> { set_pagination_header(:catalogs) }, unless: :authenticated_catalog?

  def index
    @catalogs = @catalogs.page(params[:page]).per(params[:per]) unless authenticated_catalog?
  end

  private

  def set_pagination_params
    params[:page] ||= 1
    params[:per] ||=  DEFAULT_PAGE_SIZE
    params[:per] = [params[:per].to_i, MAX_PAGE_SIZE].min
  end

  def log_request
    APILog.create(
      user: @current_user,
      endpoint: request.fullpath,
      remote_ip: request.remote_ip,
      payload: params
    )
  end

  def find_catalogs
    @catalogs = if authenticated_catalog?
                  [@authenticated_catalog]
                elsif @current_user.system_admin?
                  Catalog.all
                else
                  @current_user.public_and_accessible_catalogs
                end
  end
end
