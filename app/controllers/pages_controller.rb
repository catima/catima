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
    @page = catalog.pages.where(:locale => locale, :slug => slug).first!
  end
end
