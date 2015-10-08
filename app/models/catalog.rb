# == Schema Information
#
# Table name: catalogs
#
#  created_at       :datetime         not null
#  deactivated_at   :datetime
#  id               :integer          not null, primary key
#  name             :string
#  other_languages  :json
#  primary_language :string           default("en"), not null
#  requires_review  :boolean          default(FALSE), not null
#  slug             :string
#  updated_at       :datetime         not null
#

class Catalog < ActiveRecord::Base
  include AvailableLocales

  before_validation :strip_empty_language

  validates_presence_of :name
  validates_presence_of :primary_language
  validates_presence_of :slug
  validates_uniqueness_of :slug
  validates_inclusion_of :primary_language, :in => :available_locales
  validate :other_languages_included_in_available_locales

  has_many :catalog_permissions, :dependent => :destroy
  has_many :items
  has_many :item_types

  def self.active
    where(:deactivated_at => nil)
  end

  def self.sorted
    order("LOWER(catalogs.name) ASC")
  end

  def active?
    deactivated_at.nil?
  end

  def deactivated_at=(date)
    super(date == "now" ? Time.zone.now : date)
  end

  private

  def strip_empty_language
    self.other_languages = (other_languages || []).reject(&:blank?)
  end

  def other_languages_included_in_available_locales
    return if ((other_languages || []) - available_locales).empty?
    errors.add(
      :other_languages,
      "can only include #{available_locales.join(', ')}"
    )
  end
end
