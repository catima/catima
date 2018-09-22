# == Schema Information
#
# Table name: groups
#
#  active      :boolean
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string
#  owner_id    :bigint(8)        not null
#  public      :boolean
#  updated_at  :datetime         not null
#

class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates_presence_of :name
  validates_presence_of :owner

  def self.public
    where(public: true)
  end
end
