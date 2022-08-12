# == Schema Information
#
# Table name: pages
#
#  catalog_id  :integer
#  created_at  :datetime         not null
#  creator_id  :integer
#  id          :integer          not null, primary key
#  locale_old  :string
#  reviewer_id :integer
#  slug        :string
#  status      :string
#  title       :jsonb
#  title_old   :text
#  updated_at  :datetime         not null
#

class Page < ApplicationRecord
  include HasSlug
  include HasLocales
  include Clone

  belongs_to :catalog
  belongs_to :creator, :class_name => "User"
  belongs_to :reviewer, :class_name => "User", optional: true

  has_many :containers, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy

  validates_presence_of :catalog
  validates_presence_of :title
  validates_slug :scope => [:catalog_id]
  validate :item_types_slug_validation

  serialize :title, HashSerializer
  locales :title

  def self.sorted
    order(:slug => :asc)
  end

  def to_param
    slug
  end

  def describe
    as_json(only: %i(slug)).merge(
      title: title_json,
      containers: containers.map(&:describe)
    )
  end

  private

  # A page & an item type should not have the same slug
  # because they have the same path structure. It could
  # lead to unpredictable behavior
  def item_types_slug_validation
    return unless catalog

    return unless catalog.item_types.exists?(slug: slug)

    errors.add :slug, I18n.t("validations.page.item_types_slug")
  end
end
