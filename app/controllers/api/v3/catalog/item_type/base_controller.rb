class API::V3::Catalog::ItemType::BaseController < API::V3::Catalog::BaseController
  before_action :find_item_type

  private

  def find_item_type
    @item_type = @catalog.item_types.not_deleted.find(params[:item_type_id])
  end
end
