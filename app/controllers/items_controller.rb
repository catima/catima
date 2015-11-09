class ItemsController < ApplicationController
  # We use this constraint to make the route less "greedy" by restricting the
  # wildcard to valid item type slugs.
  module Constraint
    def self.matches?(request)
      catalog = Catalog.active.where(:slug => request[:catalog_slug]).first!
      slug = request[:item_type_slug]
      slug && catalog.item_types.where(:slug => slug).exists?
    end
  end

  include ControlsCatalog
  include ControlsSearchResults

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
