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

class User::GroupInvitationForm < ActiveType::Record[User]
  attr_accessor :group

  before_validation :assign_random_password

  validates_presence_of :group
  validates_presence_of :invited_by

  after_commit :generate_token_and_deliver_invitation,
               :unless => :reset_password_token

  def self.policy_class
    User::GroupInvitationFormPolicy
  end

  private

  def assign_random_password
    self.password = SecureRandom.urlsafe_base64(16)
    self.password_confirmation = password
  end

  def generate_token_and_deliver_invitation
    token = set_reset_password_token
    InvitationsMailer.group(self, group, token).deliver_later
  end
end
