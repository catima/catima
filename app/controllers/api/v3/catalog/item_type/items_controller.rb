class API::V3::Catalog::ItemType::ItemsController < API::V3::Catalog::ItemType::BaseController
  include ControlsItemSorting

  after_action -> { set_pagination_header(:items) }, only: :index

  def index
    authorize(@catalog, :item_type_items_index?)

    @items = @item_type.items
    @items = @items.page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog, :item_type_item_show?)

    @item = @item_type.items.find(params[:item_id])
  end

  private

  def apply_search(items)
    return items if params[:search].blank?

    items.where("LOWER(search_data_#{I18n.locale}) LIKE ?", "%#{params[:search].downcase}%")
  end

  def apply_except(items)
    return items if params[:except].blank?

    items.where("id NOT IN (#{params[:except].join(', ')})")
  end
end
