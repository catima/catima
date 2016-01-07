class CatalogAdmin::CSVImportsController < CatalogAdmin::BaseController
  def new
    build_csv_import
    authorize(@csv_import)
  end

  def create
    build_csv_import
    authorize(@csv_import)
    @csv_import.file = params.require(:csv_import)[:file]

    if @csv_import.save
      redirect_to(catalog_admin_items_path, :notice => import_created_message)
    else
      render("new")
    end
  end

  private

  helper_method :item_type

  def build_csv_import
    @csv_import = begin
      CSVImport.new do |import|
        import.creator = current_user
        import.item_type = item_type
      end
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
    @item_type ||= begin
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
    end
  end
end
