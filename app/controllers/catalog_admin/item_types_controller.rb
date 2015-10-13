class CatalogAdmin::ItemTypesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  def new
    build_item_type
    authorize(@item_type)
  end

  def create
    build_item_type
    authorize(@item_type)
    if @item_type.update(item_type_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  private

  def build_item_type
    @item_type = catalog.item_types.new
  end

  def item_type_params
    params.require(:item_type).permit(:name, :slug)
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_item_type_path
    else catalog_admin_dashboard_path
    end
  end

  def created_message
    "Created item type “#{@item_type.name}”."
  end
end
