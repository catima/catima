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
    @browse = Search::Browse.new(
      :item_type => item_type,
      :field => browse_field,
      :value => browse_value,
      :page => params[:page]
    )
  end

  def show
    @item = item_type.items.find(params[:id]).behaving_as_type
  end

  private

  attr_reader :item_type
  helper_method :item_type, :items_referenced_by_fields

  def find_item_type
    @item_type =
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end

  def browse_field
    @browse_field ||= item_type.fields.find do |field|
      params[field.slug].present?
    end
  end

  def browse_value
    return if browse_field.nil?
    params[browse_field.slug]
  end

  def items_referenced_by_fields
    @item.referenced_by_fields.each_with_object({}) do |field, result|
      browse = Search::Browse.new(
        :item_type => field.item_type,
        :field => field,
        :value => @item.id.to_s
      )
      next if browse.empty?
      result[field] = browse
      yield(field, browse) if block_given?
    end
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
