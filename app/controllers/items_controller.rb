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
  before_action :set_item_type_variant

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

  # If an item type-specific view is desired, it can be specified by naming
  # the view with a special syntax, making use of the item type slug.
  # For example: `show.html+vehicles.erb`
  def set_item_type_variant
    # The slug should already be sanitized, but we do this just in case.
    safe_slug = item_type.slug.downcase.gsub(/[^a-z0-9\-]/, "")
    request.variant = safe_slug.to_sym
  end
end
