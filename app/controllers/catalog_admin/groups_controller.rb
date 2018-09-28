class CatalogAdmin::GroupsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def index
  end

  def new
    build_group
  end

  def create
    build_group
    if @group.update(group_params)
      redirect_to after_create_path, notice: created_message
    else
      render 'new'
    end
  end

  def edit
    find_group
    authorize @group
  end

  def show
    find_group
    authorize @group
  end

  def update
    find_group
    authorize @group
    respond_to do |format|
      format.html { update_group }
      format.js { update_catalog_permissions_for_group }
    end
  end

  def destroy
    find_group
    authorize(@group)
    @group.destroy
    redirect_to catalog_admin_users_path, notice: destroyed_message
  end

  def user_scoped?
    true
  end

  private

  def build_group
    @group = catalog.groups.new do |model|
      model.active = true
      model.public = false
      model.owner = current_user
    end
  end

  def find_group
    @group = Group.find_by(id: params[:id], catalog: catalog)
  end

  def update_group
    if @group.update(group_params)
      redirect_to catalog_admin_users_path, notice: updated_message
    else
      render 'edit'
    end
  end

  def update_catalog_permissions_for_group
    group = Group.find_by(id: params['id'], catalog: catalog)
    @catalog_permission = CatalogPermission.find_or_create_by(catalog_id: catalog.id, group_id: group.id)
    authorize @catalog_permission
    @catalog_permission.save
    @catalog_permission.update(role: params['role'])
  end

  def group_params
    params.require(:group).permit %i(name description active public)
  end

  def created_message
    "Group “#{@group.name}” has been created."
  end

  def updated_message
    "Group “#{@group.name}” has been saved."
  end

  def destroyed_message
    "Group “#{@group.name}” has been deleted."
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_group_path
    else catalog_admin_users_path
    end
  end
end
