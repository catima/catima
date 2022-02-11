class CatalogAdmin::SuggestionsController < CatalogAdmin::BaseController
  include ControlsCatalog
  include ControlsItemList

  before_action :find_item_type
  before_action :find_item
  before_action :find_suggestion

  def destroy
    authorize(@suggestion)
    @suggestion.destroy
    redirect_to edit_catalog_admin_item_path(id: @item.id)
  end

  def update_processed
    authorize(@suggestion)
    @suggestion.process
    redirect_to edit_catalog_admin_item_path(id: @item.id)
  end

  private

  def find_item_type
    @item_type = catalog.item_types.find_by!(slug: params[:item_type_slug])
  end

  def find_item
    @item = @item_type.public_items.find(params[:item_id]).behaving_as_type
  end

  def find_suggestion
    @suggestion = @item.suggestions.find(params[:id])
  end
end
