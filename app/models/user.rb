# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jti                    :string           not null
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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_users_on_jti                   (jti) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#

def auth_providers
  providers = []
  providers.push :facebook if ENV['AUTH_FACEBOOK_APP_ID'].presence
  providers.push :github if ENV['AUTH_GITHUB_APP_ID'].presence
  providers.push :shibboleth if ENV['AUTH_SHIB_APP_ID'].presence
  providers
end

# rubocop:disable Metrics/ClassLength
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: auth_providers if auth_providers.count > 0

  include User::Roles
  include AvailableLocales
  include HasDeletion

  belongs_to(
    :invited_by,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    inverse_of: :users_invited,
    optional: true
  )

  has_many :catalog_permissions, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :searches, dependent: :nullify, inverse_of: :user
  has_many :my_groups, class_name: 'Group', foreign_key: 'owner_id', dependent: :destroy, inverse_of: :owner
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many(
    :items_as_creator,
    class_name: 'Item',
    foreign_key: 'creator_id',
    dependent: :nullify,
    inverse_of: :creator
  )
  has_many(
    :items_as_updater,
    class_name: 'Item',
    foreign_key: 'updater_id',
    dependent: :nullify,
    inverse_of: :updater
  )
  has_many(
    :users_invited,
    class_name: 'User',
    foreign_key: 'invited_by_id',
    dependent: :nullify,
    inverse_of: :invited_by
  )
  has_many(
    :advanced_search_configurations,
    foreign_key: 'creator_id',
    dependent: :nullify,
    inverse_of: :creator
  )
  has_many(
    :advanced_searches,
    foreign_key: 'creator_id',
    dependent: :nullify,
    inverse_of: :creator
  )
  has_many(
    :simple_searches,
    foreign_key: 'creator_id',
    dependent: :nullify,
    inverse_of: :creator
  )
  has_many(
    :pages_as_creator,
    class_name: 'Page',
    foreign_key: 'creator_id',
    dependent: :nullify,
    inverse_of: :creator
  )
  has_many(
    :pages_as_reviewer,
    class_name: 'Page',
    foreign_key: 'reviewer_id',
    dependent: :nullify,
    inverse_of: :reviewer
  )
  has_many(
    :exports,
    dependent: :nullify,
    inverse_of: :user
  )
  has_many(
    :reviews,
    class_name: 'Item',
    foreign_key: 'reviewer_id',
    dependent: :nullify,
    inverse_of: :reviewer
  )
  has_many(
    :entry_logs,
    foreign_key: :author_id,
    # Can't be nullify (database constraint).
    dependent: :restrict_with_exception,
    inverse_of: :author
  )
  has_many(
    :ahoy_events,
    class_name: 'Ahoy::Event',
    dependent: :nullify,
    inverse_of: :user
  )
  has_many(
    :ahoy_visits,
    class_name: 'Ahoy::Visit',
    dependent: :nullify,
    inverse_of: :user
  )
  has_many(
    :suggestions,
    dependent: :nullify,
    inverse_of: :user
  )
  has_many(
    :api_logs,
    dependent: :nullify,
    inverse_of: :user
  )

  accepts_nested_attributes_for :catalog_permissions

  validates_presence_of :primary_language
  validates_inclusion_of :primary_language, :in => :available_locales
  validates_uniqueness_of :email, scope: [:deleted_at]

  default_scope { not_deleted }
  scope :with_deleted, -> { unscope(where: :deleted_at) }

  before_create :set_jti_uuid

  def self.sorted
    order(:email => "ASC")
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

  def self.search(search)
    if search
      where("email ILIKE ?", "%#{sanitize_sql_like(search)}%")
    else
      all
    end
  end

  def self.filter_by_role(filter, catalog)
    if filter
      users_for_role(filter, catalog)
    else
      all
    end
  end

  def describe
    as_json(only: %i[id email])
  end

  def jwt_subject
    id
  end

  def public_and_accessible_catalogs
    catalog_ids =
      Catalog.not_deactivated.where(visible: true, restricted: false)
             .pluck(:id) + # everyone
      Catalog.not_deactivated.where(visible: true, restricted: true, id: (catalog_permissions + groups.where(active: true)
             .map(&:catalog_permissions))
             .flatten.select { |p| p.role_at_least?("member") }
             .pluck(:catalog_id)).pluck(:id) + # members+
      Catalog.not_deactivated.where(visible: false, restricted: true, id: (catalog_permissions + groups.where(active: true)
             .map(&:catalog_permissions))
             .flatten.select { |p| p.role_at_least?("editor") }
             .pluck(:catalog_id)).pluck(:id) + # staff
      Catalog.not_deactivated.where(visible: false, restricted: false, id: (catalog_permissions + groups.where(active: true)
              .map(&:catalog_permissions))
              .flatten.select { |p| p.role_at_least?("editor") }
              .pluck(:catalog_id)).pluck(:id) # staff
    Catalog.where(id: catalog_ids)
  end

  def destroy
    # User are only soft deleted.

    User.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      touch(:deleted_at)
      # rubocop:enable Rails/SkipsModelValidations

      # We reset the provider uid and name to avoid conflicts if the user
      # creates a new account in the futur with this provider.
      update(uid: nil, provider: nil)
    end
  end

  def active_for_authentication?
    # Overrided from Devise :authenticatable module.
    # This allow to check each requests if the user is still autorized to be
    # authenticated (not blocked, still active, etc).
    # We add not_deleted to the list of checks.
    # Note: This isn't mandatory because the default scope will already filter
    # who can log-in and who can't. It's there only for Devise to be in line with
    # the deleted_at philosophy (and 2 two checks is better than one).
    super && not_deleted?
  end

  def inactive_message
    # Overrided from Devise :authenticatable module.
    # This message is used when :active_for_authentication? return false.
    # If the user is deleted, we display an invalid credentials message instead
    # of a not active account message.
    not_deleted? ? super : :invalid
  end

  def will_save_change_to_email?
    # Overrided from :validatable module to remove the validation of the
    # uniqueness of the email. It is used when we want to create a new user
    # with the same email as a deleted user.
    false
  end

  def self.users_for_role(role, catalog)
    return User.none unless catalog.not_deactivated?
    return User.all if role.empty?
    return User.all if role == "user"
    return User.none unless CatalogPermission::ROLE_OPTIONS.include?(role)

    # Users directly associated with the catalog
    direct_users = User.joins(:catalog_permissions)
                       .where(catalog_permissions: { catalog_id: catalog.id, role: role })

    # Users indirectly associated via active groups
    group_users = User.joins(memberships: { group: :catalog_permissions })
                      .where(catalog_permissions: { catalog_id: catalog.id, role: role })
                      .where(groups: { active: true })

    # Combine and ensure uniqueness
    User.where(id: (direct_users.pluck(:id) + group_users.pluck(:id)).uniq)
  end

  private

  def set_jti_uuid
    self.jti ||= SecureRandom.uuid
  end
end
# rubocop:enable Metrics/ClassLength
