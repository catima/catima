class API::V3::Catalog::ItemType::ItemsController < API::V3::Catalog::ItemType::BaseController
  include ControlsItemSorting

  def index
    @items = @item_type.items
    @items.page(params[:page] ).per(params[:per] || DEFAULT_PAGE_SIZE)
  end

  def show
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
