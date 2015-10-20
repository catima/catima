class CatalogAdmin::ItemsController < CatalogAdmin::BaseController
  before_action :find_item_type
  layout "catalog_admin/data/form"

  def index
    # TODO: how to sort?
    @items = policy_scope(item_scope)
    @fields = @item_type.visible_fields
    render("index", :layout => "catalog_admin/data")
  end

  def show
    find_item
  end

  private

  def find_item_type
    @item_type = catalog.item_types
                 .where(:slug => params[:item_type_slug])
                 .first!
  end

  def item_scope
    catalog.items_of_type(@item_type)
  end

  def find_item
    @item = item_scope.find(params[:id])
  end
end
