# == Schema Information
#
# Table name: items
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  creator_id     :integer
#  data           :json
#  id             :integer          not null, primary key
#  item_type_id   :integer
#  review_status  :string           default("not-ready"), not null
#  reviewer_id    :integer
#  search_data_de :text
#  search_data_en :text
#  search_data_fr :text
#  search_data_it :text
#  updated_at     :datetime         not null
#

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
  include ControlsItemList

  before_action :find_item_type
  before_action :set_item_type_variant

  def index
    @browse = ItemList::Filter.new(
      :item_type => item_type,
      :field => browse_field,
      :value => browse_value,
      :page => params[:page]
    )
    @item = find_item
  end

  def show
    begin
      @item = item_type.public_items.find(params[:id]).behaving_as_type
    rescue ActiveRecord::RecordNotFound => e
      @item_type = item_type
      @item_id = params[:id]
      render 'missing'
    end
  end

  protected

  def track
    track_event("catalog_front")
  end

  private

  attr_reader :item_type

  helper_method :item_type

  def find_item_type
    @item_type =
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end

  def browse_field
    @browse_field ||= item_type.fields.find do |field|
      params[field.slug].present?
    end
  end

  def find_item
    return if browse_field.nil?

    begin
      Item.find(params[browse_field.slug])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def browse_value
    return if browse_field.nil?

    params[browse_field.slug]
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
