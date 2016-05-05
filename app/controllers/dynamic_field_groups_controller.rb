class DynamicFieldGroupsController < ApplicationController
  before_action :set_dynamic_field_group, only: [:show, :edit, :update, :destroy, :shift_child_field_or_group]

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
    @dynamic_field_group.parent_dynamic_field_group_id = params[:parent_dynamic_field_group_id] if params[:parent_dynamic_field_group_id]
  end

  # GET /dynamic_field_groups/1/edit
  def edit
    @child_dynamic_fields_and_dynamic_field_groups = @dynamic_field_group.child_dynamic_fields_and_dynamic_field_groups
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

    if @dynamic_field_group.child_dynamic_fields_and_dynamic_field_groups.length > 0
      respond_to do |format|
        format.html { redirect_to edit_dynamic_field_group_path(@dynamic_field_group), alert: 'You must delete all child dynamic fields and dynamic field groups before you can delete this dynamic field group.' }
        format.json { render json: 'You must delete all child dynamic fields and dynamic field groups before you can delete this dynamic field group.', status: :unprocessable_entity }
      end
    else
      @dynamic_field_group.destroy
      respond_to do |format|
        format.html { redirect_to dynamic_fields_url , notice: 'Dynamic Field Group was successfully deleted.'}
        format.json { head :no_content }
      end
    end
  end
  
  # PATCH/PUT /dynamic_field_groups/1/shift_child_field_or_group
  def shift_child_field_or_group
    
    success = false
    
    if params[:dynamic_field_or_dynamic_field_group_string_key].present?
      dynamic_field_or_dynamic_field_group_string_key = params[:dynamic_field_or_dynamic_field_group_string_key]
      direction = params[:direction]
      
      # Get children
      @child_dynamic_fields_and_dynamic_field_groups = @dynamic_field_group.child_dynamic_fields_and_dynamic_field_groups
      
      # Determine which children need to be swapped
      index_of_child_to_shift = @child_dynamic_fields_and_dynamic_field_groups.index { |child| child.string_key == dynamic_field_or_dynamic_field_group_string_key }
      if direction == 'up'
        index_of_other_child_to_swap_with = index_of_child_to_shift - 1
        index_of_other_child_to_swap_with = @child_dynamic_fields_and_dynamic_field_groups.length - 1 if index_of_other_child_to_swap_with < 0
      elsif direction == 'down'
        index_of_other_child_to_swap_with = index_of_child_to_shift + 1
        index_of_other_child_to_swap_with = 0 if index_of_other_child_to_swap_with >= @child_dynamic_fields_and_dynamic_field_groups.length
      end
      
      # Swap order of children to swap
      child1 = @child_dynamic_fields_and_dynamic_field_groups[index_of_child_to_shift]
      child2 = @child_dynamic_fields_and_dynamic_field_groups[index_of_other_child_to_swap_with]
      @child_dynamic_fields_and_dynamic_field_groups[index_of_child_to_shift] = child2
      @child_dynamic_fields_and_dynamic_field_groups[index_of_other_child_to_swap_with] = child1
      
      # Re-number the order all elements in @child_dynamic_fields_and_dynamic_field_groups to correct any existing ordering issues
      DynamicFieldGroup.transaction do
        @child_dynamic_fields_and_dynamic_field_groups.each_with_index do |child, index|
          child.sort_order = index
          child.save!
        end
        success = true
      end
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to edit_dynamic_field_group_path(@dynamic_field_group), notice: 'Child ordering was successfully updated.' }
      else
        format.html { redirect_to edit_dynamic_field_group_path(@dynamic_field_group), :flash => { :error => "An unexpected error occurred." } }
      end
    end
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_field_group
      @dynamic_field_group = DynamicFieldGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_field_group_params
      params.require(:dynamic_field_group).permit(:string_key, :display_label, :parent_dynamic_field_group_id, :sort_order, :is_repeatable, :xml_translation, :dynamic_field_group_category_id, :created_by_id, :updated_by_id)
    end
end
