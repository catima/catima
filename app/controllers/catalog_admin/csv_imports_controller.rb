class CatalogAdmin::CSVImportsController < CatalogAdmin::BaseController
  layout "catalog_admin/data/form"

  def new
    build_csv_import
    authorize(@csv_import)
  end

  def create
    build_csv_import(csv_import_params)
    authorize(@csv_import)

    begin
      @csv_import.save!
    rescue ActiveRecord::RecordInvalid
      return render "new"
    rescue StandardError => e
      return redirect_to(
        new_catalog_admin_csv_import_path,
        :alert => "#{I18n.t('catalog_admin.csv_imports.create.error')}: #{e.message}"
      )
    end

    redirect_to(
      catalog_admin_items_path,
      :notice => import_created_message,
      :details => import_created_message_details
    )
  end

  private

  helper_method :item_type

  def build_csv_import(params=nil)
    @csv_import = CSVImport.new(params) do |import|
      import.creator = current_user
      import.item_type = item_type
      import.file_encoding = "detect"
    end
  end

  def import_created_message
    message = "#{success_count} #{I18n.t('catalog_admin.csv_imports.create.imported_successfully')}".dup
    message << " #{failure_count} #{I18n.t('catalog_admin.csv_imports.create.skipped')}." if @csv_import.failures.any?
    message
  end

  def import_created_message_details
    messages = []

    # Add failure messages
    @csv_import.failures.each do |failure|
      failure.column_errors.each do |column_name, errors|
        next if errors.empty?

        # Displayed like this: [Line X] <Column>: <Row value> => <Errors list>
        line_info = failure.line_number ? "#{I18n.t('catalog_admin.csv_imports.create.line_info', line_number: failure.line_number)} " : ""
        icon_html = view_context.content_tag(:i, '', class: 'fa fa-times-circle text-danger')
        messages << (icon_html + " #{line_info}#{column_name}: #{failure.row[column_name]} => #{errors.join(', ')}")
      end
    end

    # Add warning messages
    unless @csv_import.warnings.empty?
      @csv_import.warnings.each do |warning|
        # Displayed like this: [Line X] <Column>: <Warning message>
        line_info = warning.line_number ? "#{I18n.t('catalog_admin.csv_imports.create.line_info', line_number: warning.line_number)} " : ""
        icon_html = view_context.content_tag(:i, '', class: 'fa fa-exclamation-triangle text-warning')
        messages << (icon_html + " #{line_info}#{warning}")
      end
    end

    messages
  end

  def success_count
    message = view_context.number_with_delimiter(@csv_import.success_count).dup

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

  def csv_import_params
    params.expect(csv_import: [:file, :file_encoding])
  end
end
