class MembershipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @memberships = current_user.memberships
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
end
