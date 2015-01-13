class FieldsetsController < ApplicationController
  before_action :set_fieldset, only: [:edit, :update, :destroy]
  before_action :require_appropriate_project_permissions!
  before_action :set_contextual_nav_options

  # GET /fieldsets/new
  def new
    @fieldset = Fieldset.new
    @fieldset.project = Project.find(params[:project_id])
  end

  # GET /fieldsets/1/edit
  def edit
  end

  # POST /fieldsets
  # POST /fieldsets.json
  def create
    @fieldset = Fieldset.new(fieldset_params)

    respond_to do |format|
      if @fieldset.save
        format.html { redirect_to edit_fieldset_path(@fieldset), notice: 'Fieldset was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /fieldsets/1
  # PATCH/PUT /fieldsets/1.json
  def update
    respond_to do |format|
      if @fieldset.update(fieldset_params)
        format.html { redirect_to edit_fieldset_path(@fieldset), notice: 'Fieldset was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /fieldsets/1
  # DELETE /fieldsets/1.json
  def destroy
    @fieldset.destroy
    respond_to do |format|
      format.html { redirect_to fieldsets_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fieldset
    @fieldset = Fieldset.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fieldset_params
    params.require(:fieldset).permit(:display_label, :project_id)
  end

  def set_contextual_nav_options

    @contextual_nav_options['nav_title']['label'] = '&laquo; Back To Fieldsets'.html_safe

    case params[:action]
    when 'new'
      @contextual_nav_options['nav_title']['url'] = fieldsets_project_path(params[:project_id])
    when 'create'
      @contextual_nav_options['nav_title']['url'] = fieldsets_project_path(params[:fieldset]['project_id'])
    else
      @contextual_nav_options['nav_title']['url'] = fieldsets_project_path(@fieldset.project)
    end

    case params[:action]
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This Fieldset', url: fieldset_path(@fieldset.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Fieldset?' } })
    end

  end

  def require_appropriate_project_permissions!

    case params[:action]
    when 'new', 'create', 'edit', 'update', 'delete'
      require_project_permission!(@project, :admin)
    else
      require_hyacinth_admin!
    end

  end
end
