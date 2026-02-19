# == Schema Information
#
# Table name: groups
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  description :string
#  identifier  :string
#  name        :string
#  public      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  catalog_id  :bigint
#  owner_id    :bigint           not null
#
# Indexes
#
#  index_groups_on_catalog_id           (catalog_id)
#  index_groups_on_name_and_catalog_id  (name,catalog_id) UNIQUE
#  index_groups_on_owner_id             (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (owner_id => users.id)
#

class Group < ApplicationRecord
  belongs_to(
    :owner,
    -> { unscope(where: :deleted_at) },
    class_name: 'User',
    :inverse_of => :my_groups
  )
  belongs_to :catalog

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :catalog_permissions, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :owner
  validates_presence_of :catalog

  validates_uniqueness_of :name, scope: :catalog

  accepts_nested_attributes_for :catalog_permissions

  after_save :assign_public_identifier, :if => :public?

  def self.public
    where(public: true)
  end

  def role_for_catalog(catalog)
    perm = catalog_permissions.where(catalog: catalog)
    options = CatalogPermission::ROLE_OPTIONS
    perm_idx = perm.map { |p| options.index(p.role) }
    perm_idx.count == 0 ? 'user' : options[perm_idx.max]
  end

  def assign_public_identifier
    # If no identifier is assigned to the group, then create a new token
    update(:identifier => generate_identifier) if identifier.blank?
  end

  def public_reachable?
    return false unless active?
    return false unless public?
    return false unless identifier?

    true
  end

  private

  # The identifier is composed of:
  # catalog slug + catalog id + group id + 8 random characters
  def generate_identifier
    catalog.slug.concat("-")
           .concat(catalog.id.to_s)
           .concat(id.to_s)
           .concat("-")
           .concat(SecureRandom.uuid.split("-").first)
  end
end
