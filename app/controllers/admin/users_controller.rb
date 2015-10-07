class Admin::UsersController < Admin::BaseController
  def new
    build_user
    # TODO: authorize
  end

  private

  def build_user
    @user = User::CreateAdminForm.new(:invited_by => current_user)
  end
end
