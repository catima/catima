class CatalogAdmin::ExportsController < CatalogAdmin::BaseController
  def index
    build_export(catalog)
    authorize(@export)
    @exports = catalog.exports.order(created_at: :desc)
    render("index", :layout => "catalog_admin/setup")
  end

  def create
    category = find_category
    build_export(catalog)
    authorize(@export)
    export = Export.create(
      user: current_user,
      catalog: catalog,
      category: category,
      status: "processing"
    )
    export.export_catalog(params[:locale])
    redirect_back fallback_location: catalog_admin_exports_path, :alert => @message
  end

  def download
    export = retrieve_export(params[:id])
    authorize(export)
    send_file(export.pathname)
  end

  private

  def build_export(catalog)
    @export = Export.new do |model|
      model.catalog = catalog
      model.user = current_user
    end
  end

  def retrieve_export(export_id)
    raise Pundit::NotAuthorizedError if export_id.blank?
    raise Pundit::NotAuthorizedError unless /^\d+$/ =~ export_id

    find_export(export_id)
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def find_export(export_id)
    Export.find(export_id)
  end

  def find_category(category=request[:category])
    @message = t(".invalid_category") unless Export::CATEGORY_OPTIONS.include? category
    category
  end

  def download_fails(message)
    redirect_to(root_path, :alert => message)
  end
end
