class API::V3::Catalog::BaseController < API::V3::BaseController
  DEFAULT_THROTTLE_TIME_WINDOW = 1
  DEFAULT_THROTTLE_MAX_REQUESTS = 5

  before_action :find_catalogs, :find_catalog
  before_action :log_request
  before_action :throttle

  def policy_scope(scope)
    super([:"api/v3", scope])
  end

  def authorize(record, query=nil)
    super([:"api/v3", record], query)
  end

  private

  def log_request
    APILog.create(
      user: @current_user,
      catalog: @catalog,
      endpoint: request.fullpath,
      remote_ip: request.remote_ip,
      payload: params
    )
  end

  def throttle
    client_ip = request.remote_ip
    key = "count:#{client_ip}:#{@catalog.id}"
    count = REDIS.get(key)

    unless count
      throttle_time_window = @catalog.throttle_time_window || DEFAULT_THROTTLE_TIME_WINDOW
      REDIS.set(key, 0)
      REDIS.expire(key, throttle_time_window)
      return true
    end

    throttle_max_requests = @catalog.throttle_max_requests || DEFAULT_THROTTLE_MAX_REQUESTS
    if count.to_i >= throttle_max_requests
      render :status => :too_many_requests, :json => { code: 'too_many_requests', message: t('api-v3.responses.too_many_requests') }
      return
    end
    REDIS.incr(key)
    true
  end

  def find_catalogs
    ids = @current_user.public_and_accessible_catalogs.pluck(:id)
    @catalogs = Catalog.where(id: ids.uniq, api_enabled: true).page(params[:page])
  end

  def find_catalog
    @catalog = @catalogs.find(params[:catalog_id])
  end
end
