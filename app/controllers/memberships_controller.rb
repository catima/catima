class MembershipsController < ApplicationController
  before_action :authenticate_user!

  def create
    return redirect_to(memberships_path, :alert => t('errors.messages.membership.no_identifier')) if params[:identifier].blank?

    group = find_group_identifier(params[:identifier])
    if group
      return redirect_to(memberships_path, :alert => t('errors.messages.membership.already_member')) if find_membership(group).present?

      build_membership(group)
      authorize(@membership)
      Membership.create(group: group, user: current_user, status: "invited")
      redirect_to(memberships_path, :notice => t('notices.membership.created', :group => group.name))
    else
      redirect_to(memberships_path, :alert => t('errors.messages.membership.identifier_does_not_exist', :identifier => params[:identifier]))
    end
  end

  def index
    @memberships = current_user.memberships.select do |m|
      m.group.active?
    end
  end

  def destroy
    membership = Membership.find params[:id]
    authorize membership
    membership.destroy
    redirect_to memberships_path
  end

  def user_scoped?
    true
  end

  private

  def build_membership(group)
    @membership = Membership.new do |model|
      model.group = group
      model.user = current_user
      model.status = :invited
    end
  end

  def find_membership(group)
    Membership.find_by(group: group, user: current_user)
  end

  def find_group_identifier(identifier)
    Group.find_by(identifier: identifier)
  end
end
