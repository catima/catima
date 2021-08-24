class Admin::LogEntriesController < Admin::BaseController
  before_action :find_catalog

  def index
    authorize(@catalog)
    @log_entries = @catalog.log_entries.ordered.page(params[:page])
  end

  private

  def find_catalog
    @catalog = Catalog.find_by(slug: params[:catalog_slug])
  end
end
