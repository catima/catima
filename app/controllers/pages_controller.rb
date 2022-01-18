# == Schema Information
#
# Table name: pages
#
#  catalog_id  :integer
#  content     :text
#  created_at  :datetime         not null
#  creator_id  :integer
#  id          :integer          not null, primary key
#  locale      :string
#  reviewer_id :integer
#  slug        :string
#  status      :string
#  title       :text
#  updated_at  :datetime         not null
#

class PagesController < ApplicationController
  include ActionView::Helpers::TagHelper

  # We use this constraint to make the route less "greedy" by restricting the
  # wildcard to valid page slugs.
  module Constraint
    def self.matches?(request)
      catalog = Catalog.not_deactivated.where(:slug => request[:catalog_slug]).first!
      slug = request[:slug]
      catalog.pages.exists?(:slug => slug)
    end
  end

  include ControlsCatalog

  def show
    slug = request[:slug]
    @page = catalog.pages.where(:slug => slug).first!
    render :show
  end

  def items
    slug = request[:slug]
    page = catalog.pages.where(:slug => slug).first!
    container = page.containers.find(request[:container_id])
    catalog = page.catalog
    item_type = catalog.item_types.where(:id => container.item_type).first!
    filter_field = container.filterable_field_id.present? ? Field.find(container.filterable_field_id) : item_type.items.first.primary_field
    @list = ::ItemList::Filter.new(
      :item_type => item_type,
      :page => params[:page],
      filter_field: filter_field,
      sort_direction: params[:sort] || container&.sort || 'ASC'
    )

    formatted_sorted_items = @list.items.map { |item| helpers.formatted_item_for_timeline(item, list: @list, container: container, filter_field: filter_field) }
    render json: { items: helpers.group_items_for_timeline(formatted_sorted_items, container: container, filter_field: filter_field) }
  end

  protected

  def track
    track_event("catalog_front")
  end
end
