class CatalogAdmin::MenuItemsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def index
    authorize(MenuItem)
    @menu_items = catalog.menu_items.all
    @catalog = catalog
  end

  def new
    build_menu_item
    authorize(@menu_item)
  end

  def edit
    find_menu_item
    authorize(@menu_item)
  end

  def create
    build_menu_item
    authorize(@menu_item)
    if @menu_item.update(menu_item_params)
      redirect_to(catalog_admin_menu_items_path, :notice => created_message)
    else
      render("new")
    end
  end

  def update
    find_menu_item
    authorize(@menu_item)
    if @menu_item.update(update_menu_item_params)
      redirect_to(catalog_admin_menu_items_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_menu_item
    authorize(@menu_item)
    @menu_item.destroy
    redirect_to(catalog_admin_menu_items_path, :notice => destroyed_message)
  end

  private

  def build_menu_item
    @menu_item = catalog.menu_items.new
  end

  def find_menu_item
    @menu_item = catalog.menu_items.where(:id => params[:id]).first!
  end

  def menu_item_params
    params.require(:menu_item).permit(
      :id, :item_type_id, :locale, :page_id, :parent_id, :rank, :slug, :title, :url
    )
  end

  # When updating a menu item, we need to make sure that page_id, item_type_id, and url
  # are set to nil if they are not present in the request params. If one of these params
  # is set in the database, the others should be nil.
  def update_menu_item_params
    menu_item_params_updated = menu_item_params

    menu_item_params_updated.merge!(:page_id => nil) if menu_item_params[:page_id].nil?
    menu_item_params_updated.merge!(:item_type_id => nil) if menu_item_params[:item_type_id].nil?
    menu_item_params_updated.merge!(:url => nil) if menu_item_params[:url].nil?

    menu_item_params_updated
  end

  def created_message
    "Menu item “#{@menu_item.title}” has been created."
  end

  def updated_message
    "Menu item “#{@menu_item.title}” has been saved."
  end

  def destroyed_message
    "Menu item “#{@menu_item.title}” has been deleted."
  end
end
