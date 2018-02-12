# == Schema Information
#
# Table name: catalogs
#
#  advertize           :boolean
#  created_at          :datetime         not null
#  custom_root_page_id :integer
#  deactivated_at      :datetime
#  id                  :integer          not null, primary key
#  name                :string
#  other_languages     :json
#  primary_language    :string           default("en"), not null
#  requires_review     :boolean          default(FALSE), not null
#  slug                :string
#  updated_at          :datetime         not null
#

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

  def home
    redirect_to send("catalog_#{catalog.snake_slug}_url")
  end
end
