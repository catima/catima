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
      sort_direction: params[:sort_direction] || container&.sort_direction || 'ASC',
    )

    formated_sorted_items = @list.items.map do |item|
      item.attributes.merge(
        title: helpers.item_has_thumbnail?(item) ? tag.div(helpers.item_list_link(@list, item, 0) { helpers.item_thumbnail(item, :class => "media-object") }, class: "pull-left mr-3") : tag.h4(helpers.item_list_link(@list, item, 0, helpers.item_display_name(item)), class: "mt-0 mb-1"),
        summary: helpers.item_summary(item),
        primary_field_value: helpers.field_value(item, item.primary_field),
        filter_field_value: filter_field.is_a?(Field::DateTime) ? filter_field.value_as_array(item, format: container&.field_format) : helpers.field_value(item, filter_field),
        group_title: filter_field.is_a?(Field::DateTime) ? Field::DateTimePresenter.new(nil, item, filter_field).value(format: container&.field_format) : helpers.field_value(item, filter_field)
      )
    end

    grouped_formated_sorted_items = filter_field.is_a?(Field::DateTime) ? formated_sorted_items.group_by { |item| container&.field_format && item[:filter_field_value].is_a?(Array) ? item[:filter_field_value].join('') : item[:filter_field_value] } : formated_sorted_items.group_by { |item| item[:filter_field_value] }
    render json: {items: grouped_formated_sorted_items}
  end

  protected

  def track
    track_event("catalog_front")
  end
end
