class CatalogAdmin::UsersController < CatalogAdmin::BaseController
  layout "catalog_admin/setup", :only => :index

  def index
    authorize(User)
    @users = policy_scope(User).sorted
  end

  def edit
    find_user
    authorize(@user)
  end

  def update
    find_user
    authorize(@user)
    if @user.update(user_params)
      redirect_to(catalog_admin_users_path, :notice => user_updated_message)
    else
      render("edit")
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    policy(@user).permit(params.require(:user))
  end

  def user_updated_message
    "#{@user.email} has been saved."
  end
end
