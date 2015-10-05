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

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include AvailableLocales

  has_many :catalog_permissions, :dependent => :destroy

  validates_presence_of :primary_language
  validates_inclusion_of :primary_language, :in => :available_locales

  def catalog_role_at_least?(catalog, role_requirement)
    # Authenticated users are always considered at least "user" level.
    return true if role_requirement == "user"

    perm = catalog_permissions.to_a.find { |p| p.catalog_id == catalog.id }
    perm && perm.role_at_least?(role_requirement)
  end

  def authenticated?
    true
  end
end
