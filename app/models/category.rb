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
  belongs_to :catalog
end
