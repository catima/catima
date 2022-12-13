class CatalogAdmin::CSVImportsController < CatalogAdmin::BaseController
  layout "catalog_admin/data/form"

  def new
    build_csv_import
    authorize(@csv_import)
  end

  def create
    build_csv_import
    authorize(@csv_import)
    @csv_import.file = params.require(:csv_import)[:file]

    sucess = begin
      @csv_import.save
    rescue StandardError => e
      flash.now[:alert] = "#{I18n.t('catalog_admin.csv_imports.create.error')}: #{e.message}"
      false
    end

    if sucess
      redirect_to(catalog_admin_items_path, :notice => import_created_message)
    else
      render("new")
    end
  end

  private

  helper_method :item_type

  def build_csv_import
    @csv_import = CSVImport.new do |import|
      import.creator = current_user
      import.item_type = item_type
    end
  end

  def import_created_message
    message = "#{success_count} imported successfully."
    message << " #{failure_count} skipped." if @csv_import.failures.any?
    message
  end

  def success_count
    message = view_context.number_with_delimiter(@csv_import.success_count)

    if @csv_import.success_count == 1
      message << " #{item_type.name}"
    else
      message << " #{item_type.name_plural}"
    end
  end

  def failure_count
    view_context.number_with_delimiter(@csv_import.failures.count)
  end

  def item_type
    @item_type ||= catalog.item_types.where(
      :slug => params[:item_type_slug]
    ).first!
  end
end
