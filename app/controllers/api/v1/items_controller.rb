class API::V1::ItemsController < ActionController::Base
  def index
    items = if (type_slug = params[:item_type]).present?
              items_scope.with_type_slug(type_slug)
            else
              items_scope
            end

    render(:json => items)
  end

  def show
    item = items_scope.find(params[:id])
    render(:json => item)
  end

  private

  def items_scope
    @_items_scope ||= begin
      catalog = Catalog.active.find_by!(:slug => params[:catalog_slug])
      catalog.public_items
             .includes(:catalog)
             .includes(:item_type)
             .includes(:item_type => :fields)
    end
  end
end
