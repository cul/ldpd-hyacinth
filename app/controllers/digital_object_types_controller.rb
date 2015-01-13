class DigitalObjectTypesController < ApplicationController
  before_action :require_hyacinth_admin!
  before_action :set_digital_object_type, only: [:show, :edit, :update, :destroy]

  # GET /digital_object_types
  # GET /digital_object_types.json
  def index
    @digital_object_types = DigitalObjectType.all
  end

  # GET /digital_object_types/1
  # GET /digital_object_types/1.json
  def show
  end

  # GET /digital_object_types/new
  def new
    @digital_object_type = DigitalObjectType.new
  end

  # GET /digital_object_types/1/edit
  def edit
  end

  # POST /digital_object_types
  # POST /digital_object_types.json
  def create
    @digital_object_type = DigitalObjectType.new(digital_object_type_params)

    respond_to do |format|
      if @digital_object_type.save
        format.html { redirect_to @digital_object_type, notice: 'Digital object type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @digital_object_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @digital_object_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /digital_object_types/1
  # PATCH/PUT /digital_object_types/1.json
  def update
    respond_to do |format|
      if @digital_object_type.update(digital_object_type_params)
        format.html { redirect_to @digital_object_type, notice: 'Digital object type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @digital_object_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /digital_object_types/1
  # DELETE /digital_object_types/1.json
  def destroy
    @digital_object_type.destroy
    respond_to do |format|
      format.html { redirect_to digital_object_types_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_digital_object_type
    @digital_object_type = DigitalObjectType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def digital_object_type_params
    params.require(:digital_object_type).permit(:string_key, :display_label, :sort_order)
  end
end
