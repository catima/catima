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

  belongs_to :catalog
  belongs_to :creator, :class_name => "User"
  belongs_to :reviewer, :class_name => "User", optional: true

  has_many :containers, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy

  validates_presence_of :catalog

  validates_presence_of :title
  serialize :title, HashSerializer

  validates_slug :scope => [:catalog_id]

  locales :title

  def self.sorted
    order(:slug => :asc)
  end

  def to_param
    slug
  end

  def describe
    as_json(only: %i(slug)).merge(
      "title": title_json,
      "containers": containers.map(&:describe)
    )
  end
end
