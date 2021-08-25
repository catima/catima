class API::V3::Catalog::ItemType::ItemsController < API::V3::Catalog::ItemType::BaseController
  include ControlsItemSorting

  after_action -> { set_pagination_header(:items) }, only: :index
  before_action :validate_sort_field, only: :index

  def index
    authorize(@catalog, :item_type_items_index?) unless authenticated_catalog?

    @items = @item_type.items
    @items = apply_sort(@items, direction: params[:direction] == 'ASC' ? 'ASC' : 'DESC')
    @items = @items.page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog, :item_type_item_show?) unless authenticated_catalog?

    @item = @item_type.items.find(params[:item_id])
  end

  private

  def validate_sort_field
    render_unprocessable_entity('invalid_sort') unless !params[:sort].present? || @item_type.fields.select(&:human_readable?).reject(&:multiple).pluck(:slug).include?(params[:sort])
  end

  def item_type
    @item_type
  end

  def apply_search(items)
    return items if params[:search].blank?

    items.where("LOWER(search_data_#{I18n.locale}) LIKE ?", "%#{params[:search].downcase}%")
  end

  def apply_except(items)
    return items if params[:except].blank?

    items.where("id NOT IN (#{params[:except].join(', ')})")
  end
end
