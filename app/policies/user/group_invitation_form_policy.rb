class User::GroupInvitationFormPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    @record.group.owner == @user
  end
end
