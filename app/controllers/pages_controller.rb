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
      locale = request[:locale]
      slug = request[:slug]
      catalog.pages.where(:locale => locale, :slug => slug).exists?
    end
  end

  include ControlsCatalog

  def show
    locale = request[:locale]
    slug = request[:slug]
    @page = catalog.pages.where(:locale => locale, :slug => slug).first!
  end
end
