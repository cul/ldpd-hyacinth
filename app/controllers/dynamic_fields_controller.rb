class DynamicFieldsController < ApplicationController
  before_action :require_hyacinth_admin!
  before_action :set_dynamic_field, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # GET /dynamic_fields
  # GET /dynamic_fields.json
  def index
    @dynamic_field_group_categories = DynamicFieldGroupCategory.all.order(:sort_order => :asc)
    respond_to do |format|
      format.html {}
      format.json {
        render json: @dynamic_field_group_categories
      }
    end
  end

  # GET /dynamic_fields/1
  # GET /dynamic_fields/1.json
  def show
  end

  # GET /dynamic_fields/new
  def new
    @dynamic_field = DynamicField.new
    @dynamic_field.parent_dynamic_field_group_id = params[:parent_dynamic_field_group_id] if params[:parent_dynamic_field_group_id]
  end

  # GET /dynamic_fields/1/edit
  def edit
  end

  # POST /dynamic_fields
  # POST /dynamic_fields.json
  def create
    @dynamic_field = DynamicField.new(dynamic_field_params)

    @dynamic_field.created_by = current_user

    respond_to do |format|
      if @dynamic_field.save
        format.html { redirect_to edit_dynamic_field_path(@dynamic_field), notice: 'Dynamic field was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_field }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_fields/1
  # PATCH/PUT /dynamic_fields/1.json
  def update

    @dynamic_field.updated_by = current_user

    respond_to do |format|
      if @dynamic_field.update(dynamic_field_params)
        format.html { redirect_to edit_dynamic_field_path(@dynamic_field), notice: 'Dynamic field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_fields/1
  # DELETE /dynamic_fields/1.json
  def destroy
    @dynamic_field.destroy

    respond_to do |format|
      format.html {
        if @dynamic_field.parent_dynamic_field_group_id.present?
          redirect_location = edit_dynamic_field_group_path(@dynamic_field.parent_dynamic_field_group_id)
        else
          redirect_location = dynamic_fields_path
        end
        redirect_to redirect_location, notice: 'Dynamic Field was successfully deleted.'
      }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dynamic_field
    @dynamic_field = DynamicField.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dynamic_field_params
    params.require(:dynamic_field).permit(:string_key, :display_label, :parent_dynamic_field_group_id, :sort_order, :dynamic_field_type, :controlled_vocabulary_id, :additional_data_json, :required_for_group_save, :is_keyword_searchable, :is_facet_field, :standalone_field_label, :is_searchable_identifier_field, :is_searchable_title_field, :is_single_field_searchable, :created_by_id, :updated_by_id)
  end

  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Dynamic Fields'.html_safe
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Dynamic Fields'.html_safe
      @contextual_nav_options['nav_title']['url'] = dynamic_fields_path
    end


    if params[:action] == 'index'
      @contextual_nav_options['nav_items'].push(label: 'Add New Dynamic Field Group', url: new_dynamic_field_group_path)
    end

  end
end
