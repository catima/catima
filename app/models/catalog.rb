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

class Catalog < ActiveRecord::Base
  include AvailableLocales
  include HasDeactivation
  include HasSlug

  belongs_to :custom_root_page, class_name: "Page"

  before_validation :strip_empty_language

  validates_presence_of :name
  validates_presence_of :primary_language
  validates_slug

  validates_inclusion_of :primary_language, :in => :available_locales
  validate :other_languages_included_in_available_locales

  has_many :advanced_searches, :dependent => :destroy
  has_many :catalog_permissions, :dependent => :destroy
  has_many :categories, -> { active }, :dependent => :destroy
  has_many :choice_sets, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :item_types, -> { active }, :dependent => :destroy
  has_many :pages, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy

  def self.sorted
    order("LOWER(catalogs.name) ASC")
  end

  def public_items
    requires_review? ? Review.public_items_in_catalog(self) : items
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

  def customization_root
    safe_slug = Zaru.sanitize!(slug)
    Rails.root.join("catalogs", safe_slug)
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
