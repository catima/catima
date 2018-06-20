class CatalogAdmin::ExportsController < CatalogAdmin::BaseController
  def index
    # TODO: create index view
  end

  def create
    catalog = find_catalog
    name = catalog.slug
    category = "Export::Catima"
    status = "processing"

    build_export(catalog)
    authorize(@export)

    Export.create(
      user: current_user,
      catalog: catalog,
      name: name,
      category: category,
      status: status
    )

    redirect_to :back
  end

  def update
    # TODO: create update method
  end

  def destroy
    # TODO: create destroy method
  end

  def download
    # TODO: add authorize
    export = Export.find_by(id: params[:id])
    send_file(export.pathname)
  end

  private

  def build_export(catalog)
    @export = Export.new do |model|
      model.catalog = catalog
      model.user = current_user
    end
  end

  def find_catalog(slug=request[:catalog_slug])
    Catalog.find_by(slug: slug)
  end
end
