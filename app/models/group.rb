# == Schema Information
#
# Table name: groups
#
#  active      :boolean
#  catalog_id  :bigint(8)
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  identifier  :string
#  name        :string
#  owner_id    :bigint(8)        not null
#  public      :boolean
#  updated_at  :datetime         not null
#

class Group < ApplicationRecord
  belongs_to :owner, -> { unscope(where: :deleted_at) }, class_name: 'User'
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
