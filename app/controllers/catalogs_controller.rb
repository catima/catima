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
      catalog_slug && Catalog.not_deactivated.exists?(:slug => catalog_slug)
    end
  end

  include ControlsCatalog
  before_action :redirect_if_data_only

  def show
  end

  protected

  def redirect_if_data_only
    redirect_to  root_path, alert: t("catalogs.data_only", catalog_name: @catalog.name) if @catalog.data_only
  end

  def track
    track_event("catalog_front")
  end
end
