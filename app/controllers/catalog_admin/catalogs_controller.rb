class CatalogAdmin::CatalogsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def update
    find_catalog
    authorize(@catalog)
    if @catalog.update(catalog_params)
      redirect_to(catalog_admin_settings_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def update_style
    find_catalog
    authorize(@catalog)
    if @catalog.update(catalog_params)
      redirect_to(catalog_admin_style_path, :notice => updated_message)
    else
      render("edit_style")
    end
  end

  private

  def find_catalog
    @catalog = Catalog.where(:slug => params[:catalog_slug]).first!
  end

  def updated_message
    "The settings for “#{@catalog.name}” catalog have been updated."
  end

  def catalog_params
    params.require(:catalog).permit(
      :name,
      :requires_review,
      :advertize,
      :custom_root_page_id,
      :style
    )
  end
end
