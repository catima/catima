# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  locale_old  :string
#  slug        :string
#  status      :string
#  title       :jsonb
#  title_old   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  catalog_id  :integer
#  creator_id  :integer
#  reviewer_id :integer
#
# Indexes
#
#  index_pages_on_catalog_id   (catalog_id)
#  index_pages_on_creator_id   (creator_id)
#  index_pages_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (reviewer_id => users.id)
#

class Page < ApplicationRecord
  include HasSlug
  include HasLocales
  include Clone

  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    :inverse_of => :pages_as_creator
  )
  belongs_to(
    :reviewer,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    :inverse_of => :pages_as_reviewer,
    optional: true
  )

  has_many :containers, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy

  validates_presence_of :catalog
  validates_presence_of :title
  validates_slug :scope => [:catalog_id]
  validate :item_types_slug_validation

  serialize :title, coder: HashSerializer
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
