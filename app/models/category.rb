# == Schema Information
#
# Table name: categories
#
#  catalog_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string
#  updated_at :datetime         not null
#

class Category < ActiveRecord::Base
  include HasFields
  include HasHumanId

  human_id :name
  validates_presence_of :name

  def self.sorted
    order("LOWER(categories.name) ASC")
  end
end
