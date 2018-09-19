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
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_admin           :boolean          default(FALSE), not null
#  uid                    :string
#  updated_at             :datetime         not null
#

def auth_providers
  providers = []
  providers.push :facebook if ENV['AUTH_FACEBOOK_APP_ID']
  providers.push :github if ENV['AUTH_GITHUB_APP_ID']
  providers.push :shibboleth if ENV['AUTH_SHIB_APP_ID']
  providers
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: auth_providers if auth_providers.count > 0

  include AvailableLocales

  belongs_to :invited_by, :class_name => "User", optional: true
  has_many :catalog_permissions, :dependent => :destroy
  has_many :favorites, :dependent => :destroy

  accepts_nested_attributes_for :catalog_permissions

  validates_presence_of :primary_language
  validates_inclusion_of :primary_language, :in => :available_locales

  def self.sorted
    order(:email => "ASC")
  end

  # TODO: refactor these methods into separate role-checker helper class?

  def catalog_role_at_least?(catalog, role_requirement)
    # Authenticated users are always considered at least "user" level.
    return true if role_requirement == "user"

    perm = catalog_permissions.to_a.find { |p| p.catalog_id == catalog.id }
    perm && perm.role_at_least?(role_requirement)
  end

  def catalog_role(catalog)
    perm = catalog_permissions.to_a.find { |p| p.catalog_id == catalog.id }
    perm ? perm.role : "user"
  end

  def catalog_visible_for_role?(catalog)
    return true if system_admin
    return catalog_role_at_least?(catalog, "editor") unless catalog.visible
    true
  end

  def can_list_item?(item)
    return false unless item.catalog.active?
    return false unless item.catalog.public_items.exists?(item.id)
    return false unless catalog_visible_for_role?(item.catalog)
    true
  end

  def admin_catalogs
    Catalog.where(:id => admin_catalog_ids)
  end

  def admin_catalog_ids
    role_catalog_ids("admin")
  end

  def reviewer_catalog_ids
    role_catalog_ids("reviewer")
  end

  def super_editor_catalog_ids
    role_catalog_ids("super-editor")
  end

  def editor_catalog_ids
    role_catalog_ids("editor")
  end

  def member_catalog_ids
    role_catalog_ids("member")
  end

  def role_catalog_ids(role)
    catalog_permissions.to_a.each_with_object([]) do |perm, admin|
      next unless perm.active?
      admin << perm.catalog_id if perm.role_at_least?(role)
    end
  end

  def admin_of_any_catalog?
    admin_catalog_ids.any?
  end

  def reviewer_of_any_catalog?
    reviewer_catalog_ids.any?
  end

  def super_editor_of_any_catalog?
    super_editor_catalog_ids.any?
  end

  def editor_of_any_catalog?
    editor_catalog_ids.any?
  end

  def member_of_any_catalog?
    member_catalog_ids.any?
  end

  def authenticated?
    true
  end

  def email_complete?
    # For OmniAuth authenticated users, CATIMA might create a temporary email
    # if no valid email has been transmitted. This temporary email is in the
    # format <username>@<provider> and does not have a domain extension.
    # Technically it is still a valid email so it will pass the validation.
    # But it is not a usual email as we need, so we validate against a more
    # complete check with a Regex string from Devise but completed for domain
    # name check.
    (email =~ /\A[^@,\s]+@[^@,\s]+\.[^@,\s]+\z/) == 0
  end

  # Devise + ActiveJob integration
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email || "#{auth.info.nickname}@#{auth.provider}"
      user.password = Devise.friendly_token[0, 20]
      user.save
    end
  end
end
