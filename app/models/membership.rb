# == Schema Information
#
# Table name: memberships
#
#  id         :bigint           not null, primary key
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_memberships_on_group_id  (group_id)
#  index_memberships_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#

class Membership < ApplicationRecord
  # Note that the status options are purposely in ascending order of privilege.
  STATUS_OPTIONS = %w(invited member admin).freeze

  belongs_to :user
  belongs_to :group

  validates_presence_of :group_id
  validates_presence_of :user_id
  validates_inclusion_of :status, :in => STATUS_OPTIONS
end
