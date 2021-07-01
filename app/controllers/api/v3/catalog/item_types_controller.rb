class API::V3::Catalog::ItemTypesController < API::V3::Catalog::BaseController
  before_action :find_item_types

  def index
    @item_types = @item_types.page(params[:page] || 1).per(params[:per] || 25)
  end

  def show
    @item_type = @item_types.find(params[:item_type_id])
  end

  private

  def find_item_types
    @item_types = @catalog.item_types.where(deactivated_at: nil)
  end
end
