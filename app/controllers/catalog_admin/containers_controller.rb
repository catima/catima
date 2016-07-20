class CatalogAdmin::ContainersController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"
  
  def edit
    find_container
    authorize(@container)
  end

  private

  def find_container
    @container = nil
    c = Container.find(params[:id])
    @container = c if catalog.id == c.page.catalog.id
  end
end
