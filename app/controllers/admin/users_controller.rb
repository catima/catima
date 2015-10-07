class Admin::UsersController < Admin::BaseController
  layout "admin/form"

  def new
    build_user
    # TODO: authorize(@user)
  end

  def create
    build_user
    # TODO: authorize(@user)
    if @user.update(user_params)
      redirect_to(admin_dashboard_path, :notice => user_created_message)
    else
      render("new")
    end
  end

  private

  def build_user
    @user = User::CreateAdminForm.new(:invited_by => current_user)
  end

  def user_params
    params.require(:user)
      .permit(:email, :primary_language, :system_admin, :catalog_ids)
  end

  def user_created_message
    "viim admin created! An invitation has been sent to #{@user.email}."
  end
end
