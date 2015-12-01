class CatalogAdmin::ApprovalsController < CatalogAdmin::BaseController
  before_action :find_item_type
  before_action :find_item

  def create
    @item.review.approved(:by => current_user)
    @item.save!

    respond_to do |f|
      f.html { redirect_to_item_edit }
      f.js
    end
  end

  def destroy
    @item.review.rejected(:by => current_user)
    @item.save!

    respond_to do |f|
      f.html { redirect_to_item_edit }
      f.js
    end
  end

  private

  def redirect_to_item_edit
    redirect_to(edit_catalog_admin_item_path(catalog, @item_type, @item))
  end

  # TODO: DRY this up with CatalogAdmin::ItemsController

  def find_item_type
    @item_type = catalog.item_types
                 .where(:slug => params[:item_type_slug])
                 .first!
  end

  def item_scope
    catalog.items_of_type(@item_type)
  end

  def find_item
    @item = item_scope.find(params[:id]).behaving_as_type
  end
end
