class CatalogAdmin::MembershipsController < CatalogAdmin::BaseController
  def new
    @group = Group.find(params['group_id'])
    @membership = @group.memberships.new
    authorize @membership
  end

  def create
    @group = Group.find(params['group_id'])
    member_emails = members_to_invite
    member_emails.each do |member_email|
      u = User.find_by email: member_email
      if u.nil?
        invite_user_to_join member_email, @group
      else
        add_user_to_group u, @group
      end
    end
    redirect_to catalog_admin_group_path(id: @group.id)
  end

  def destroy
    membership = Membership.find params[:id]
    authorize membership
    membership.destroy
    redirect_to catalog_admin_group_path(id: params[:group_id])
  end

  def user_scoped?
    true
  end

  private

  def members_to_invite
    m = params['members_to_invite'].first
    m.split("\n").map { |line| line.scan(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,5}/) }.flatten
  end

  def invite_user_to_join(email, group)
    user = User::GroupInvitationForm.new(
      group: group,
      invited_by: current_user,
      email: email
    )
    authorize user
    user.save
    add_user_to_group(user, group)
  end

  def add_user_to_group(user, group)
    return if user.groups.include? group

    membership = group.memberships.new do |m|
      m.user = user
      m.status = :member
    end
    authorize membership
    membership.save
    InvitationsMailer.membership(current_user, membership).deliver_later
  end
end
