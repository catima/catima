class CatalogAdmin::UsersController < CatalogAdmin::BaseController
  layout "catalog_admin/setup", :only => :index

  def index
    authorize(User)
    @users = policy_scope(User).sorted
  end

  def new
    build_user
    # authorize(@user)
  end

  def create
    build_user
    authorize(@user)
    if @user.update(user_params)
      redirect_to(catalog_admin_users_path, :notice => user_created_message)
    else
      logger.debug(@user.errors.inspect)
      render("new")
    end
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

  def build_user
    @user = User::CreateForm.new(:invited_by => current_user)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    policy(@user).permit(params.require(:user))
  end

  def user_created_message
    "An invitation has been sent to #{@user.email}."
  end

  def user_updated_message
    "#{@user.email} has been saved."
  end
end
