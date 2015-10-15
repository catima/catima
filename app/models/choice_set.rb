# == Schema Information
#
# Table name: choice_sets
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deactivated_at :datetime
#  id             :integer          not null, primary key
#  name           :string
#  updated_at     :datetime         not null
#

class ChoiceSet < ActiveRecord::Base
  include HasDeactivation

  belongs_to :catalog

  validates_presence_of :catalog
  validates_presence_of :name
end
