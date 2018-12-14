# == Schema Information
#
# Table name: memberships
#
#  created_at :datetime         not null
#  group_id   :bigint(8)
#  id         :bigint(8)        not null, primary key
#  status     :string
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#

class Membership < ApplicationRecord
  # Note that the status options are purposely in ascending order of privilege.
  STATUS_OPTIONS = %w(invited member admin).freeze

  belongs_to :user
  belongs_to :group

  validates_presence_of :group_id
  validates_presence_of :user_id
end
