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
  # We use this constraint to make the route less "greedy" by restricting the
  # wildcard to valid page slugs.
  module Constraint
    def self.matches?(request)
      catalog = Catalog.active.where(:slug => request[:catalog_slug]).first!
      slug = request[:slug]
      catalog.pages.where(:slug => slug).exists?
    end
  end

  include ControlsCatalog

  def show
    slug = request[:slug]
    @page = catalog.pages.where(:slug => slug).first!
  end

  protected

  def track_action
    ahoy.track catalog.slug, request.path_parameters.merge(:scope => "catalog_front")
  end
end
