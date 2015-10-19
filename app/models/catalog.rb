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
  include HasDeactivation
  include HasSlug

  before_validation :strip_empty_language

  validates_presence_of :name
  validates_presence_of :primary_language
  validates_slug

  validates_inclusion_of :primary_language, :in => :available_locales
  validate :other_languages_included_in_available_locales

  has_many :catalog_permissions, :dependent => :destroy
  has_many :choice_sets
  has_many :items
  has_many :item_types

  def self.sorted
    order("LOWER(catalogs.name) ASC")
  end

  def valid_locale?(locale)
    valid_locales.include?(locale.to_s)
  end

  def valid_locales
    [primary_language, other_languages].flatten.compact.uniq
  end

  def items_of_type(item_type)
    items.merge(item_type.items)
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
