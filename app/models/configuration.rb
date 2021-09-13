# == Schema Information
#
# Table name: configurations
#
#  created_at         :datetime         not null
#  default_catalog_id :integer
#  id                 :integer          not null, primary key
#  root_mode          :string           default("listing"), not null
#  updated_at         :datetime         not null
#

class Configuration < ApplicationRecord
  belongs_to :default_catalog, :class_name => "Catalog", optional: true
  validates_presence_of :root_mode
  validates_inclusion_of :root_mode, :in => %w(listing custom redirect)
  validate :cannot_redirect_if_no_active_catalogs

  def active_redirect_catalog
    return nil unless root_mode == "redirect"
    return nil unless default_catalog && default_catalog.not_deactivated?

    default_catalog
  end

  private

  def cannot_redirect_if_no_active_catalogs
    return unless root_mode == "redirect"
    return if Catalog.not_deactivated.any?

    errors.add(:root_mode, "no catalogs to redirect to")
  end
end
