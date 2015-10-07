# == Schema Information
#
# Table name: users
#
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  id                     :integer          not null, primary key
#  invited_by_id          :integer
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  primary_language       :string           default("en"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_admin           :boolean          default(FALSE), not null
#  updated_at             :datetime         not null
#

class User::CreateAdminForm < ActiveType::Record[User]
  attr_accessor :catalog_ids

  after_initialize :set_system_admin_if_no_catalogs

  before_validation :assign_random_password
  before_validation :assign_permissions

  validates_presence_of :invited_by
  validate :at_least_one_catalog_assigned

  after_commit :generate_token_and_deliver_invitation,
               :unless => :reset_password_token

  def catalog_choices
    # TODO: sort
    # TODO: only consider active catalogs
    Catalog.all
  end

  private

  def set_system_admin_if_no_catalogs
    return if catalog_choices.any?
    self.system_admin = true
  end

  def assign_random_password
    self.password = SecureRandom.urlsafe_base64(16)
    self.password_confirmation = password
  end

  def assign_permissions
    self.catalog_permissions = (catalog_ids || []).map do |catalog_id|
      CatalogPermission.new(
        :catalog_id => catalog_id,
        :user => self,
        :role => "admin"
      )
    end
  end

  def at_least_one_catalog_assigned
    return if system_admin? || admin_of_any_catalog?
    if catalog_choices.any?
      errors.add(:catalog_ids, "at least one must be selected")
    else
      errors.add(:system_admin, "must be checked, since there are no catalogs")
    end
  end

  def generate_token_and_deliver_invitation
    token = set_reset_password_token
    # TODO
    logger.debug("delivering invitation: #{token}")
  end
end
