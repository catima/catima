# == Schema Information
#
# Table name: catalogs
#
#  advertize           :boolean
#  created_at          :datetime         not null
#  custom_root_page_id :integer
#  deactivated_at      :datetime
#  id                  :integer          not null, primary key
#  logo_id             :string
#  name                :string
#  navlogo_id          :string
#  other_languages     :json
#  primary_language    :string           default("en"), not null
#  requires_review     :boolean          default(FALSE), not null
#  restricted          :boolean          default(FALSE), not null
#  slug                :string
#  style               :jsonb
#  updated_at          :datetime         not null
#  visible             :boolean          default(TRUE), not null
#

class Catalog < ApplicationRecord
  include AvailableLocales
  include HasDeactivation
  include HasSlug
  include HasSqlSlug

  belongs_to :custom_root_page, class_name: "Page", optional: true

  before_validation :strip_empty_language
  before_validation :check_activation_status

  validates_presence_of :name
  validates_presence_of :primary_language
  validates_slug

  validates_inclusion_of :primary_language, :in => :available_locales
  validate :other_languages_included_in_available_locales

  serialize :style, HashSerializer

  has_many :advanced_searches, :dependent => :destroy
  has_many :catalog_permissions, :dependent => :destroy
  has_many :categories, -> { active }
  has_many :all_categories, :class_name => "Category", :dependent => :destroy
  has_many :choice_sets, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :item_types, -> { active }
  has_many :all_item_types, :class_name => "ItemType", :dependent => :destroy
  has_many :pages, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy
  has_many :exports, :dependent => :destroy
  has_many :groups, dependent: :destroy
  has_many :advanced_search_configurations, dependent: :destroy

  attachment :logo, type: :image
  attachment :navlogo, type: :image

  def self.sorted
    order(Arel.sql("LOWER(catalogs.name) ASC"))
  end

  def self.unique_inactive_slug(active_slug)
    slug = nil
    loop do
      slug = active_slug + "-inactive#{Random.rand.to_s[2, 4]}"
      break if Catalog.slug_unique?(slug)
    end
    slug
  end

  def self.slug_unique?(slug)
    Catalog.find_by(slug: slug).nil?
  end

  def self.valid?(slug)
    c = Catalog.find_by(slug: slug)
    !c.nil? && c.active?
  end

  def self.overrides
    Dir.exist?(Rails.root.join('catalogs')) ? Dir.entries(Rails.root.join('catalogs')).select { |f| Catalog.valid? f } : []
  end

  def public?
    visible && !restricted
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

  def valid_locale(locale=I18n.locale)
    valid_locale?(locale) ? locale.to_s : primary_language
  end

  def items_of_type(item_type)
    items.merge(item_type.items)
  end

  def customization_root
    safe_slug = Zaru.sanitize!(slug)
    Rails.root.join("catalogs", safe_slug)
  end

  def inactive_suffix?
    !(slug =~ /([a-z0-9\-]+)-inactive[0-9][0-9][0-9][0-9]$/).nil?
  end

  def custom_style(elem)
    stl = JSON.parse(style)
    stl[elem] || {}
  end

  def snake_slug
    slug.tr('-', '_')
  end

  private

  def strip_empty_language
    self.other_languages = (other_languages || []).reject(&:blank?)
  end

  def check_activation_status
    if deactivated_at.nil?
      remove_inactive_suffix_from_slug
    else
      add_inactive_suffix_to_slug
    end
  end

  def add_inactive_suffix_to_slug
    return if inactive_suffix?

    update(slug: Catalog.unique_inactive_slug(slug))
  end

  def remove_inactive_suffix_from_slug
    return unless inactive_suffix?

    m = /([a-z0-9\-]+)(-inactive[0-9][0-9][0-9][0-9])$/.match(slug)
    new_slug = m[1]
    n = 0
    until Catalog.slug_unique?(new_slug)
      n += 1
      new_slug = m[1] + n.to_s
    end
    update(slug: new_slug)
  end

  def other_languages_included_in_available_locales
    return if ((other_languages || []) - available_locales).empty?

    errors.add(
      :other_languages,
      "can only include #{available_locales.join(', ')}"
    )
  end
end
