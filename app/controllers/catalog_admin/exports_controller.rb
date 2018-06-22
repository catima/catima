class CatalogAdmin::ExportsController < CatalogAdmin::BaseController
  def index
    catalog = find_catalog
    build_export(catalog)
    authorize(@export)
    @exports = Export.all.order(created_at: :desc)

    render("index", :layout => "catalog_admin/setup")
  end

  def create
    catalog = find_catalog
    category = find_category
    build_export(catalog)
    authorize(@export)
    # Export async task is triggered with the after_create callback
    Export.create(
      user: current_user,
      catalog: catalog,
      name: catalog.slug,
      category: category,
      status: "processing"
    )

    redirect_to :back, :alert => @message
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

  # TODO: add translations
  def retrieve_export(export_id)
    download_fails("Export id not found") if export_id.blank?
    download_fails("Export id invalid") unless /^\d+$/ =~ export_id
    find_export(export_id)
  rescue ActiveRecord::RecordNotFound
    download_fails("Export not found")
  end

  def find_export(export_id)
    Export.find(export_id)
  end

  def find_catalog(slug=request[:catalog_slug])
    Catalog.find_by(slug: slug)
  end

  def find_category(category=request[:category])
    @message = "Export category invalid" unless Export::CATEGORY_OPTIONS.include? category
    category
  end

  def download_fails(message)
    redirect_to(root_path, :alert => message)
  end
end
