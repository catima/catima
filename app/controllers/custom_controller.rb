# This controller renders ERB templates that are placed in this location:
# catalogs/[catalog-slug]/views/custom/
#
class CustomController < ApplicationController
  # We use this constraint to make the route less "greedy" by restricting the
  # wildcard to only match views that exist in the custom/ directory.
  module Constraint
    def self.matches?(request)
      catalog = Catalog.not_deactivated.where(:slug => request[:catalog_slug]).first!
      view = CustomController.slug_to_view(request[:slug])
      return false if view.blank?

      dir = Rails.root.join("catalogs", catalog.slug, "views", "custom")
      Dir[dir.join("#{view}.*.erb")].any?
    end
  end

  def self.slug_to_view(slug)
    slug.downcase.gsub(/[^a-z0-9\-]/, "")
  end

  include ControlsCatalog

  def show
    render(self.class.slug_to_view(params[:slug]))
  end

  private

  helper_method :items_of_type

  def items_of_type(type_slug)
    @items_of_type ||= {}
    @items_of_type[type_slug] ||= begin
      type = catalog.item_types.where(:slug => type_slug.to_s.downcase).first!
      type.sorted_items
    end
  end
end
