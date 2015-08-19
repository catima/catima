class SchemaFieldsController < ApplicationController
  before_action :set_schema_field, only: [:show, :edit, :update, :destroy]
  
  def index
    @schema_fields = SchemaField.all
  end


  def show
  end


  def new
    @schema_element = SchemaElement.find(params[:schema_element_id])
    @schema_field = @schema_element.schema_fields.build
  end


  def edit
  end


  def create
    @schema_element = SchemaElement.find(params[:schema_element_id])
    @schema_field = @schema_element.schema_fields.build(schema_field_params)
    respond_to do |format|
      if @schema_field.save
        format.html { redirect_to edit_schema_element_path(@schema_field.schema_element), notice: 'Element property was successfully created.' }
        format.json { render :show, status: :created, location: @schema_field }
      else
        format.html { render :new }
        format.json { render json: @schema_field.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @schema_field.update(schema_field_params)
        format.html { redirect_to edit_schema_element_path(@schema_field.schema_element), notice: 'Element property was successfully updated.' }
        format.json { render :show, status: :ok, location: @schema_field }
      else
        format.html { render :edit }
        format.json { render json: @schema_field.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    schema_element = @schema_field.schema_element
    @schema_field.destroy
    respond_to do |format|
      format.html { redirect_to edit_schema_element_path(schema_element), notice: 'Element property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  

  private
    def set_schema_field
      @schema_field = SchemaField.find(params[:id])
      @schema_element = @schema_field.schema_element
    end
    
    def schema_field_params
      params.require(:schema_field).permit(:name, :definition, :description, :schema_element)
    end

end
