# rubocop:disable Metrics/ClassLength
class CatalogAdmin::ItemsController < CatalogAdmin::BaseController
  include ControlsItemSorting

  before_action :find_item_type
  layout "catalog_admin/data/form"

  def index
    @items = apply_sort(policy_scope(item_scope))
    @items = @items.page(params[:page]).per(25)
    @fields = @item_type.all_list_view_fields
    render("index", :layout => "catalog_admin/data")
  end

  def show
    find_item
    authorize(@item)
  end

  def new
    build_item
    authorize(@item)
  end

  def edit
    find_item
    authorize(@item)
  end

  def create
    build_item
    authorize(@item)
    if @item.update_and_log(item_params, author: current_user, catalog: @catalog)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def duplicate
    find_item
    authorize(@item)
    @item = @item.dup
    render("new")
  end

  def update
    find_item
    authorize(@item)
    @item.updater = current_user
    if @item.update_and_log(item_params, author: current_user, catalog: @catalog)
      redirect_to({ :action => "index" }, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_item
    authorize(@item)
    @item.destroy_and_log(author: current_user, catalog: @catalog)
    redirect_to({ :action => "index" }, :notice => deleted_message)
  end

  def upload
    build_item
    authorize(@item)
    uploaded_file = params[:files]
    uploaded_file = uploaded_file[0]
    fld_id = params[:field].to_s.gsub(/[^a-zA-Z0-9_-]/, '')
    raise ActionController::BadRequest, "Invalid field parameter" if fld_id.blank?

    upload_dir = File.join('upload', params[:catalog_slug], fld_id)
    upload_path = File.join('public', upload_dir)
    FileUtils.mkdir_p(upload_path)
    timestamp = Time.current.to_fs(:number)
    field = @item_type.all_fields.find { |candidate| candidate.uuid == params[:field].to_s }
    processed_file = process_uploaded_file(uploaded_file, field, upload_dir, timestamp)
    render :json => {
      :status => 'ok', :processed_file => processed_file,
      :catalog => params[:catalog_slug],
      :item_type => params[:item_type_slug], :field => fld_id
    }
  end

  def search
    build_simple_search
    redirect_to :action => index unless @saved_search.update(simple_search_params)

    @search_results = ItemList::SimpleSearchAdminResult.new(
      :catalog => catalog,
      :query => params[:q],
      :page => params[:page],
      :item_type_slug => params[:item_type_slug],
      :search_uuid => @saved_search.uuid
    )
    @items = apply_sort(policy_scope(@search_results.items))
    @items = @items.page(params[:page]).per(25)
    @fields = @item_type.all_list_view_fields
    render("index", :layout => "catalog_admin/data")
  end

  private

  attr_reader :item_type

  def find_item_type
    @item_type = catalog.item_types
                        .where(:slug => params[:item_type_slug])
                        .first!
  end

  def item_scope
    params[:status] = nil unless Review::STATUS_OPTIONS.include?(params[:status])

    scope = catalog.items_of_type(@item_type)
    scope = scope.where(review_status: params[:status]) if params[:status].present?
    scope
  end

  def find_item
    @item = item_scope.find(params[:id]).behaving_as_type
  end

  def build_item
    @item = @item_type.items.new.tap do |item|
      item.catalog = catalog
      item.creator = current_user
      item.updater = current_user
    end.behaving_as_type
  end

  def item_params
    params.expect(
      item: [:submit_for_review,
             *@item.data_store_permitted_attributes,
             *@item.fields.flat_map(&:custom_item_permitted_attributes)]
    )
  end

  # The upload endpoint is shared by file and image fields, but their storage
  # rules are intentionally kept separate.
  def process_uploaded_file(uploaded_file, field, upload_dir, timestamp)
    if field.is_a?(Field::Image)
      process_image_upload(uploaded_file, upload_dir, timestamp)
    else
      process_file_upload(uploaded_file, upload_dir, timestamp)
    end
  end

  # Generic file fields always preserve the uploaded file as-is.
  def process_file_upload(uploaded_file, upload_dir, timestamp)
    original_filename = format_filename(uploaded_file.original_filename)
    file_path = File.join(upload_dir, "#{timestamp}_#{original_filename}")
    destination = Rails.public_path.join(file_path)
    destination.binwrite(uploaded_file.read)

    processed_file_metadata(uploaded_file, file_path, destination)
  end

  # Image fields convert formats that browsers cannot display to JPEG.
  def process_image_upload(uploaded_file, upload_dir, timestamp)
    return process_file_upload(uploaded_file, upload_dir, timestamp) unless browser_incompatible_image?(uploaded_file)

    original_filename = format_filename(uploaded_file.original_filename)
    file_path = File.join(upload_dir, "#{timestamp}_#{jpeg_filename(original_filename)}")
    destination = Rails.public_path.join(file_path)
    ImageTools.convert_to_jpeg(uploaded_file.tempfile.path, destination)

    processed_file_metadata(
      uploaded_file,
      file_path,
      destination,
      :name => jpeg_filename(uploaded_file.original_filename),
      :type => 'image/jpeg'
    )
  end

  def processed_file_metadata(uploaded_file, file_path, destination, options={})
    {
      :name => options.fetch(:name, uploaded_file.original_filename),
      :path => file_path,
      :type => options.fetch(:type, uploaded_file.content_type),
      :size => destination.size
    }
  end

  def after_create_path
    case params[:commit]
    when I18n.t('add_another') then { :action => "new" }
    else { :action => "index" }
    end
  end

  %w(created updated deleted).each do |verb|
    define_method("#{verb}_message") do
      "The selected item has been #{verb}."
    end
  end

  def format_filename(fname)
    ext = File.extname(fname)
    basename = fname.slice(0, fname.length - ext.length)
    basename.gsub(/[^0-9_\-a-zA-Z]/, '') + ext
  end

  def browser_incompatible_image?(uploaded_file)
    uploaded_file.content_type.to_s.in?(%w[image/heic image/heif image/tiff image/x-tiff]) ||
      File.extname(uploaded_file.original_filename).downcase.in?(%w[.heic .heif .tif .tiff])
  end

  def jpeg_filename(fname)
    "#{File.basename(fname, File.extname(fname))}.jpg"
  end

  def build_simple_search
    @saved_search = scope.new do |model|
      model.creator = current_user if current_user.authenticated?
    end
  end

  def simple_search_params
    params.permit(:q)
  end

  def scope
    catalog.simple_searches
  end
end

# rubocop:enable Metrics/ClassLength
