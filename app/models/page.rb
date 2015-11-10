# == Schema Information
#
# Table name: pages
#
#  catalog_id  :integer
#  content     :text
#  created_at  :datetime         not null
#  creator_id  :integer
#  id          :integer          not null, primary key
#  locale      :string
#  reviewer_id :integer
#  slug        :string
#  status      :string
#  title       :text
#  updated_at  :datetime         not null
#

class Page < ActiveRecord::Base
  include HasSlug

  belongs_to :catalog
  belongs_to :creator, :class_name => "User"
  belongs_to :reviewer, :class_name => "User"

  validates_presence_of :catalog
  validates_presence_of :content
  validates_presence_of :locale
  validates_presence_of :title

  validates_slug :scope => [:catalog_id, :locale]

  def self.sorted
    order(:slug => :asc, :locale => :asc)
  end

  def to_param
    slug
  end
end
