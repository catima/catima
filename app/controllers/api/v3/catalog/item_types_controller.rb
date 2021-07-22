class API::V3::Catalog::ItemTypesController < API::V3::Catalog::BaseController
  before_action :find_item_types

  after_action -> { set_pagination_header(:item_types) }, only: :index

  def index
    authorize(@catalog,:item_types_index?)

    @item_types = @item_types.page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog,:item_type_show?)

    @item_type = @item_types.find(params[:item_type_id])
  end

  private

  def find_item_types
    @item_types = @catalog.item_types.where(deactivated_at: nil)
  end
end
