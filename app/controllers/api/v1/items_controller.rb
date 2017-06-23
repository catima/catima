class API::V1::ItemsController < ActionController::Base
  InvalidItemType = Class.new(RuntimeError)

  rescue_from InvalidItemType do |exception|
    status = 400
    error = {
      :status => status,
      :error => "Bad request",
      :message => exception.message
    }
    render(:json => error, :status => status)
  end

  def index
    items = items_scope.with_type(item_type)
    render(:json => API::V1::PaginationSerializer.new("items", items, params))
  end

  def show
    item = items_scope.find(params[:id])
    render(:json => item)
  end

  private

  def item_type
    return nil if params[:item_type].blank?

    item_type = catalog.item_types.where(:slug => params[:item_type]).first
    if item_type.nil?
      raise InvalidItemType, "item_type not found: #{params[:item_type]}"
    end
    item_type
  end

  def catalog
    @_catalog ||= Catalog.active.find_by!(:slug => params[:catalog_slug])
  end

  def items_scope
    @_items_scope ||= begin
      catalog.public_items
             .includes(:catalog)
             .includes(:item_type)
             .includes(:item_type => :fields)
    end
  end
end
