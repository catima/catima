class Admin::TemplateStoragesController < Admin::BaseController
  layout "admin/form"

  def new
    build_template_storage
    authorize(@template_storage)
  end

  def create
    build_template_storage
    authorize(@template_storage)
    if @template_storage.update(template_storage_params)
      redirect_to(admin_dashboard_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_template_storage
    authorize(@template_storage)
  end

  def update
    find_template_storage
    authorize(@template_storage)
    if @template_storage.update(template_storage_params)
      redirect_to(admin_dashboard_path, :notice => updated_message)
    else
      render("edit")
    end
  end

   def destroy
    find_template_storage
    authorize(@template_storage)
    @template_storage.destroy
    redirect_to(admin_dashboard_path, :notice => destroyed_message)
  end


  private

  def build_template_storage
    @template_storage = TemplateStorage.new
  end

  def find_template_storage
    @template_storage = TemplateStorage.where(:id => params[:id]).first!
  end

  def template_storage_params
    params.require(:template_storage).permit(
      :body,
      :path,
      :locale,
      :handler,
      :partial,
      :format
    )
  end

  def created_message
    "The “#{@template_storage.path}” template has been created."
  end

  def updated_message
    "The “#{@template_storage.path}” storage has been updated."
  end

  def destroyed_message
    "#{@template_storage.path} has been deleted."
  end

end