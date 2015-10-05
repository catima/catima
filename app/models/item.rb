# == Schema Information
#
# Table name: items
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  creator_id   :integer
#  data         :json
#  id           :integer          not null, primary key
#  item_type_id :integer
#  reviewer_id  :integer
#  status       :string
#  updated_at   :datetime         not null
#

class Item < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :item_type
  belongs_to :creator, :class_name => "User"
  belongs_to :reviewer, :class_name => "User"

  validates_presence_of :catalog
  validates_presence_of :creator
  validates_presence_of :item_type

  validates_inclusion_of :status,
                         :in => %w(ready rejected approved),
                         :allow_nil => true
end
