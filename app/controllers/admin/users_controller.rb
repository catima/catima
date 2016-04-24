class Admin::UsersController < Admin::BaseController
  layout "admin/form"

  def new
    build_admin_form
    authorize(@user)
  end

  def create
    build_admin_form
    authorize(@user)
    if @user.update(admin_form_params)
      redirect_to(admin_dashboard_path, :notice => user_created_message)
    else
      render("new")
    end
  end

  def edit
    find_user
    build_default_catalog_permissions
    authorize(@user)
    authorize(Catalog, :index?) # b/c we show all catalogs user is assigned to
  end

  def update
    find_user
    authorize(@user)
    if @user.update(user_params)
      redirect_to(admin_dashboard_path, :notice => user_updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_user
    authorize(@user)
    @user.destroy
    redirect_to(admin_dashboard_path, :notice => user_destroyed_message)
  end

  private

  def build_admin_form
    @user = User::AdminInvitationForm.new(:invited_by => current_user)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def build_default_catalog_permissions
    Catalog.sorted.each do |catalog|
      next if @user.catalog_permissions.find { |p| p.catalog_id == catalog.id }
      @user.catalog_permissions.build(:catalog => catalog, :role => "user")
    end
  end

  def user_params
    policy(@user).permit(params.require(:user))
  end

  def admin_form_params
    params.require(:user)
      .permit(:email, :primary_language, :system_admin, :catalog_ids => [])
  end

  def user_created_message
    "CATIMA admin created! An invitation has been sent to #{@user.email}."
  end

  def user_updated_message
    "#{@user.email} has been saved."
  end

  def user_destroyed_message
    "#{@user.email} has been deleted."
  end
end
