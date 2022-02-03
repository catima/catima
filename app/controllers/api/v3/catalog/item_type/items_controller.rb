class API::V3::Catalog::ItemType::ItemsController < API::V3::Catalog::ItemType::BaseController
  attr_reader :item_type

  include ControlsItemSorting

  before_action :find_items
  before_action :find_item, only: [:show, :suggestions]
  before_action :validate_sort_field, only: :index
  after_action -> { set_pagination_header(:items) }, only: [:index]
  after_action -> { set_pagination_header(:suggestions) }, only: [:suggestions]

  def index
    authorize(@catalog, :item_type_items_index?) unless authenticated_catalog?

    @items = apply_sort(@items, direction: params[:direction] == 'ASC' ? 'ASC' : 'DESC')
    @items = @items.page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog, :item_type_item_show?) unless authenticated_catalog?
    @fields = @item_type.fields
    @fields = @fields.where(restricted: false) unless authenticated_catalog? || @current_user.catalog_role_at_least?(@catalog, "editor")
  end

  def suggestions
    authorize(@catalog, :item_type_item_suggestions?) unless authenticated_catalog?
    @suggestions = @item.suggestions.ordered.page(params[:page]).per(params[:per])
    render 'api/v3/catalog/shared/suggestions'
  end

  private

  def find_items
    @items = (authenticated_catalog? || @current_user.catalog_role_at_least?(@catalog, "editor")) ? @item_type.items : @catalog.public_items.where(item_type_id: @item_type.id)
  end

  def find_item
    @item = @items.find(params[:item_id])
  end

  def validate_sort_field
    render_unprocessable_entity('invalid_sort') unless params[:sort].blank? || @item_type.fields.select(&:human_readable?).reject(&:multiple).pluck(:slug).include?(params[:sort])
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
