class Admin::EntryLogsController < Admin::BaseController
  before_action :find_catalog

  def index
    authorize(@catalog)
    @entry_logs = @catalog.entry_logs.ordered.page(params[:page])
  end

  private

  def find_catalog
    @catalog = Catalog.find_by(slug: params[:catalog_slug])
  end
end
