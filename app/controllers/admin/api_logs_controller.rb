class Admin::APILogsController < Admin::BaseController
  before_action :find_catalog

  def index
    authorize(@catalog)
    @api_logs = @catalog.api_logs
  end

  private

  def find_catalog
    @catalog = Catalog.find_by(slug: params[:catalog_slug])
  end
end
