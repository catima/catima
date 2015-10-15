# == Schema Information
#
# Table name: choices
#
#  choice_set_id :integer
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  long_name     :text
#  short_name    :string
#  updated_at    :datetime         not null
#

class Choice < ActiveRecord::Base
  belongs_to :choice_set

  validates_presence_of :choice_set
  validates_presence_of :long_name
  validates_presence_of :short_name
end
