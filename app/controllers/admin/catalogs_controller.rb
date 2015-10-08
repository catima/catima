class Admin::CatalogsController < Admin::BaseController
  layout "admin/form"

  def new
    build_catalog
  end

  def update
    find_catalog
    authorize(@catalog)
    if @catalog.update(catalog_params)
      redirect_to(admin_dashboard_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  private

  def build_catalog
    @catalog = Catalog.new
  end

  def find_catalog
    @catalog = Catalog.find(params[:id])
  end

  def catalog_params
    params.require(:catalog).permit(:deactivated_at)
  end

  def updated_message
    if catalog_params.key?(:deactivated_at)
      @catalog.active? ? "Catalog reactivated." : "Catalog deactivated."
    else
      "Catalog updated."
    end
  end
end
