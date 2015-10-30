class ItemsController < ApplicationController
  include CatalogSite

  before_action :find_item_type

  def index
    @items = item_type.sorted_items
  end

  def show
  end

  private

  attr_reader :item_type
  helper_method :fields, :item_type

  def find_item_type
    @item_type =
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end
end
