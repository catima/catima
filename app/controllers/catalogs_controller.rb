class CatalogsController < ApplicationController
  # We use this constraint to make the route less "greedy" by restricting the
  # wildcard to valid catalog slugs.
  module Constraint
    def self.matches?(request)
      catalog_slug = request[:catalog_slug]
      catalog_slug && Catalog.active.where(:slug => catalog_slug).exists?
    end
  end

  include ControlsCatalog

  def show
  end
end
