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

class User::InvitationForm < ActiveType::Record[User]
  # TODO: test!
  # TODO: look for ways to share code with User::AdminInvitationForm

  before_validation :assign_random_password
  before_validation :assign_self_to_permissions
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
    # TODO
    # InvitationsMailer.user(self, token).deliver_later
  end
end
