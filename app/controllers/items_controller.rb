class ItemsController < ApplicationController
  include CatalogSite

  before_action :find_item_type

  def index
    @items = item_type.sorted_items
  end

  def show
    @item = item_type.items.find(params[:id]).behaving_as_type
  end

  private

  attr_reader :item_type
  helper_method :item_type

  def find_item_type
    @item_type =
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end
end
