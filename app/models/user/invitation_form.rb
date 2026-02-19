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

class User::InvitationForm < ActiveType::Record[User]
  # TODO: look for ways to share code with User::AdminInvitationForm

  attr_accessor :catalog

  before_validation :assign_random_password
  before_validation :assign_self_to_permissions
  validates_presence_of :catalog
  validates_presence_of :invited_by

  after_commit :generate_token_and_deliver_invitation,
               :unless => :reset_password_token

  def self.policy_class
    User::InvitationFormPolicy
  end

  private

  def assign_random_password
    self.password = SecureRandom.urlsafe_base64(16)
    self.password_confirmation = password
  end

  def assign_self_to_permissions
    (catalog_permissions || []).each do |perm|
      perm.user = self
    end
  end

  def generate_token_and_deliver_invitation
    token = set_reset_password_token
    InvitationsMailer.user(self, catalog, token).deliver_later
  end
end
