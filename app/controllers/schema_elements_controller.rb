class SchemaElementsController < ApplicationController
  before_action :set_schema_element, only: [:show, :edit, :update, :destroy]

  # GET /schema_elements
  # GET /schema_elements.json
  def index
    @schema_elements = SchemaElement.all
  end

  # GET /schema_elements/1
  # GET /schema_elements/1.json
  def show
  end

  # GET /schema_elements/new
  def new
    @instance = Instance.find(params[:instance_id])
    @schema_element = @instance.schema_elements.build
  end

  # GET /schema_elements/1/edit
  def edit
  end

  # POST /schema_elements
  # POST /schema_elements.json
  def create
    @instance = Instance.find(params[:instance_id])
    @schema_element = @instance.schema_elements.build(schema_element_params)
    respond_to do |format|
      if @schema_element.save
        format.html { redirect_to edit_instance_path(@schema_element.instance), notice: 'Database element was successfully created.' }
        format.json { render :show, status: :created, location: @schema_element }
      else
        format.html { render :new }
        format.json { render json: @schema_element.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schema_elements/1
  # PATCH/PUT /schema_elements/1.json
  def update
    respond_to do |format|
      if @schema_element.update(schema_element_params)
        format.html { redirect_to edit_instance_path(@schema_element.instance), notice: 'Schema element was successfully updated.' }
        format.json { render :show, status: :ok, location: @schema_element }
      else
        format.html { render :edit }
        format.json { render json: @schema_element.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schema_elements/1
  # DELETE /schema_elements/1.json
  def destroy
    instance = @schema_element.instance
    @schema_element.destroy
    respond_to do |format|
      format.html { redirect_to edit_instance_path(instance), notice: 'Database element was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schema_element
      @schema_element = SchemaElement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schema_element_params
      params.require(:schema_element).permit(:name, :description, :element_type, :options, :instance_id)
    end
end
