# == Schema Information
#
# Table name: catalog_permissions
#
#  id         :integer          not null, primary key
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :integer
#  group_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_catalog_permissions_on_catalog_id  (catalog_id)
#  index_catalog_permissions_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (user_id => users.id)
#

class CatalogPermission < ApplicationRecord
  # Note that the roles are purposely in ascending order of privilege.
  # This is to help the implementation of `role_at_least?`.
  ROLE_OPTIONS = %w(user member editor super-editor reviewer admin).freeze

  delegate :not_deactivated?, :to => :catalog

  belongs_to :catalog
  belongs_to :user, optional: true
  belongs_to :group, optional: true

  validates_presence_of :catalog
  validates_presence_of :role

  validates_inclusion_of :role, :in => ROLE_OPTIONS

  def self.higher_permission(perm1, perm2)
    ROLE_OPTIONS.index(perm1.role) > ROLE_OPTIONS.index(perm2.role) ? perm1 : perm2
  end

  # Since every Catima user account is a user in every catalog
  # we remove this role from the filter options.
  def self.filter_options
    ROLE_OPTIONS.reject { |role| role == 'user' }
  end

  def role_at_least?(role_requirement)
    requirement_index = ROLE_OPTIONS.index(role_requirement.to_s)
    return false if requirement_index.nil?

    ROLE_OPTIONS.index(role) >= requirement_index
  end
end
