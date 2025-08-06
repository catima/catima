class CatalogAdmin::ExportsController < CatalogAdmin::BaseController
  def index
    build_export
    authorize(@export)

    @exports = catalog.exports.order(created_at: :desc)

    render("index", :layout => "catalog_admin/setup")
  end

  def new
    category = find_category

    build_export(category)
    authorize(@export)

    render("new", :layout => "catalog_admin/setup")
  end

  def create
    build_export
    authorize(@export)

    if @export.update(export_params)
      @export.export_catalog(params[:locale])
      redirect_to(catalog_admin_exports_path)
    else
      render("new", :layout => "catalog_admin/setup")
    end
  end

  def download
    export = retrieve_export(params[:id])
    authorize(export)
    send_file(export.pathname)
  end

  private

  def export_params
    params.require(:export).permit(
      :category, :status, :with_files
    )
  end

  def build_export(category=nil)
    @export = catalog.exports.new do |model|
      model.user = current_user
      model.category = category
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

  def find_category(category=params[:category])
    raise Pundit::NotAuthorizedError unless Export::CATEGORY_OPTIONS.include? category

    category
  end

  def download_fails(message)
    redirect_to(root_path, :alert => message)
  end
end
