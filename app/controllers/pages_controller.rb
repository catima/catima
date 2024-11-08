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

  def items_for_line
    slug = request[:slug]
    page = catalog.pages.where(:slug => slug).first!
    container = page.containers.find(request[:container_id])
    catalog = page.catalog
    item_type = catalog.item_types.where(:id => container.item_type).first!
    sort_field = container.sort_field_id.present? ? Field.find(container.sort_field_id) : item_type.items.first.primary_field
    @list = ::ItemList::Filter.new(
      :item_type => item_type,
      :page => params[:page],
      sort_type: container.sort,
      sort_field: sort_field,
      sort: params[:sort] || Container::Sort.direction(container.sort)
    )

    formatted_sorted_items = @list.items.map { |item| helpers.formatted_item_for_line(item, list: @list, sort_field: sort_field) }
    render json: helpers.group_items_for_line(formatted_sorted_items, sort_field: sort_field)
  end

  protected

  def track
    track_event("catalog_front")
  end
end
