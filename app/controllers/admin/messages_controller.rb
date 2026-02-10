class Admin::MessagesController < Admin::BaseController
  before_action :set_message, only: [:edit, :update, :destroy]

  def index
    authorize Message, :index?
    @messages = Message.order(created_at: :desc).includes(:catalog)
  end

  def new
    authorize Message, :create?
    @message = Message.new(active: false, severity: 'info', scope: 'admin')
    @catalogs = Catalog.not_deactivated.sorted
  end

  def edit
    authorize @message, :update?
    @catalogs = Catalog.not_deactivated.sorted
  end

  def create
    authorize Message, :create?
    @message = Message.new(message_params)

    if @message.save
      redirect_to admin_messages_path, notice: t('admin.messages.created')
    else
      @catalogs = Catalog.not_deactivated.sorted
      render :new
    end
  end

  def update
    authorize @message, :update?

    if @message.update(message_params)
      redirect_to admin_messages_path, notice: t('admin.messages.updated')
    else
      @catalogs = Catalog.not_deactivated.sorted
      render :edit
    end
  end

  def destroy
    authorize @message, :destroy?
    @message.destroy
    redirect_to admin_messages_path, notice: t('admin.messages.deleted')
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.expect(message: [:text, :severity, :scope, :active, :starts_at, :ends_at, :catalog_id])
  end
end
