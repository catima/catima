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

  def create
    build_item
    authorize(@item)
    if @item.update(item_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_item
    authorize(@item)
  end

  def update
    find_item
    authorize(@item)
    if @item.update(item_params)
      redirect_to({ :action => "index" }, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_item
    authorize(@item)
    @item.destroy
    redirect_to({ :action => "index" }, :notice => deleted_message)
  end

  def upload
    build_item
    authorize(@item)
    uploaded_file = params[:files]
    uploaded_file = uploaded_file[0]
    fld_id = params[:field]
    upload_dir = File.join('upload', params[:catalog_slug], fld_id)
    upload_path = File.join('public', upload_dir)
    FileUtils.mkdir_p(upload_path)
    timestamp = Time.now.to_i.to_formatted_s(:number)
    local_fname = "#{timestamp}_" + format_filename(uploaded_file.original_filename)
    file_path = File.join(upload_dir, local_fname)
    File.open(Rails.root.join('public', file_path), 'wb') do |fp|
      fp.write(uploaded_file.read)
    end
    processed_file = {
      :name => uploaded_file.original_filename, :path => file_path,
      :type => uploaded_file.content_type, :size => uploaded_file.size
    }
    render :json => {
      :status => 'ok', :processed_file => processed_file,
      :catalog => params[:catalog_slug],
      :item_type => params[:item_type_slug], :field => fld_id
    }
  end

  private

  attr_reader :item_type

  def find_item_type
    @item_type = catalog.item_types
                 .where(:slug => params[:item_type_slug])
                 .first!
  end

  def item_scope
    catalog.items_of_type(@item_type)
  end

  def find_item
    @item = item_scope.find(params[:id]).behaving_as_type
  end

  def build_item
    @item = @item_type.items.new.tap do |item|
      item.catalog = catalog
      item.creator = current_user
    end.behaving_as_type
  end

  def item_params
    params.require(:item).permit(
      :submit_for_review,
      *@item.data_store_permitted_attributes,
      *@item.fields.flat_map(&:custom_item_permitted_attributes)
    )
  end

  def after_create_path
    case params[:commit]
    when /another/i then { :action => "new" }
    else { :action => "index" }
    end
  end

  %w(created updated deleted).each do |verb|
    define_method("#{verb}_message") do
      "#{@item_type.name} “#{view_context.default_display_name(@item)}” "\
      "has been #{verb}."
    end
  end

  def format_filename(fname)
    ext = File.extname(fname)
    basename = fname.slice(0, fname.length - ext.length)
    basename.gsub(/[^0-9_\-a-zA-Z]/, '') + ext
  end
end
