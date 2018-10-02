# == Schema Information
#
# Table name: catalog_permissions
#
#  catalog_id :integer
#  created_at :datetime         not null
#  group_id   :integer
#  id         :integer          not null, primary key
#  role       :string
#  updated_at :datetime         not null
#  user_id    :integer
#

class CatalogPermission < ApplicationRecord
  # Note that the roles are purposely in ascending order of privilege.
  # This is to help the implementation of `role_at_least?`.
  ROLE_OPTIONS = %w(user member editor super-editor reviewer admin).freeze

  delegate :active?, :to => :catalog

  belongs_to :catalog
  belongs_to :user, optional: true
  belongs_to :group, optional: true

  validates_presence_of :catalog
  validates_presence_of :role

  validates_inclusion_of :role, :in => ROLE_OPTIONS

  def self.higher_permission(perm1, perm2)
    ROLE_OPTIONS.index(perm1.role) > ROLE_OPTIONS.index(perm2.role) ? perm1 : perm2
  end

  def role_at_least?(role_requirement)
    requirement_index = ROLE_OPTIONS.index(role_requirement.to_s)
    return false if requirement_index.nil?

    ROLE_OPTIONS.index(role) >= requirement_index
  end
end
