class DynamicFieldGroupsController < ApplicationController
  before_action :set_dynamic_field_group, only: [:show, :edit, :update, :destroy]

  # GET /dynamic_field_groups
  # GET /dynamic_field_groups.json
  def index
    @dynamic_field_groups = DynamicFieldGroup.all
  end

  # GET /dynamic_field_groups/1
  # GET /dynamic_field_groups/1.json
  def show
  end

  # GET /dynamic_field_groups/new
  def new
    @dynamic_field_group = DynamicFieldGroup.new
  end

  # GET /dynamic_field_groups/1/edit
  def edit
    @child_dynamic_fields_and_dynamic_field_groups = @dynamic_field_group.get_child_dynamic_fields_and_dynamic_field_groups
  end

  # POST /dynamic_field_groups
  # POST /dynamic_field_groups.json
  def create
    @dynamic_field_group = DynamicFieldGroup.new(dynamic_field_group_params)

    @dynamic_field_group.created_by = current_user

    respond_to do |format|
      if @dynamic_field_group.save
        format.html { redirect_to edit_dynamic_field_group_path(@dynamic_field_group), notice: 'Dynamic field group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_field_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_field_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_field_groups/1
  # PATCH/PUT /dynamic_field_groups/1.json
  def update

    @dynamic_field_group.updated_by = current_user

    respond_to do |format|
      if @dynamic_field_group.update(dynamic_field_group_params)
        format.html { redirect_to edit_dynamic_field_group_path(@dynamic_field_group), notice: 'Dynamic field group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_field_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_field_groups/1
  # DELETE /dynamic_field_groups/1.json
  def destroy
    @dynamic_field_group.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_field_groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_field_group
      @dynamic_field_group = DynamicFieldGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_field_group_params
      params.require(:dynamic_field_group).permit(:string_key, :display_label, :parent_dynamic_field_group_id, :sort_order, :is_repeatable, :xml_datastream_id, :xml_translation_json, :dynamic_field_group_category_id, :created_by_id, :updated_by_id)
    end
end
