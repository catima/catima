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

  include User::Roles
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
