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

  def edit
    find_item_type
    authorize(@item_type)
  end

  def update
    find_item_type
    authorize(@item_type)
    if @item_type.update(item_type_params)
      redirect_to(
        catalog_admin_item_type_fields_path(catalog, @item_type),
        :notice => updated_message
      )
    else
      render("edit")
    end
  end

  private

  def build_item_type
    @item_type = catalog.item_types.new
  end

  def find_item_type
    @item_type = catalog.item_types.where(:slug => params[:slug]).first!
  end

  def item_type_params
    params.require(:item_type).permit(
      :name_de, :name_plural_de,
      :name_en, :name_plural_en,
      :name_fr, :name_plural_fr,
      :name_it, :name_plural_it,
      :slug)
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_item_type_path
    else catalog_admin_item_type_fields_path(catalog, @item_type)
    end
  end

  def created_message
    "The “#{@item_type.name_primary}” item type has been created."
  end

  def updated_message
    "The “#{@item_type.name_primary}” item type has been updated."
  end
end
