class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :enabled_dynamic_fields, :edit_enabled_dynamic_fields, :update_enabled_dynamic_fields, :edit_project_permissions, :update_project_permissions, :fieldsets]
  before_action :require_appropriate_permissions!
  before_action :set_contextual_nav_options

  # GET /projects
  # GET /projects.json
  def index
    if current_user.is_admin?
      @projects = Project.all
    else
      projects_that_user_is_admin_of = current_user.project_permissions.where(:is_project_admin => true)

      if projects_that_user_is_admin_of.length > 0
        @projects = Project.where(:id => projects_that_user_is_admin_of.map{|project_permission|project_permission.project.id})
      else
        @projects = []
      end
    end
  end

  # GET /projects/1
  def show
    respond_to do |format|
      format.html { redirect_to edit_project_path(@project) }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit/:type
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    if params[:commit_to_fedora]
      @project.set_commit_to_fedora_flag
    end

    success = @project.save

    respond_to do |format|
      if success
        format.html { redirect_to edit_project_path(@project), notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update

    if params[:commit_to_fedora]
      @project.set_commit_to_fedora_flag
    end

    respond_to do |format|
      if @project.update(project_params)
        format.html {
          redirect_to edit_project_path(@project), notice: 'Project was successfully updated.'
        }
        format.json { head :no_content }
      else
        format.html {
          render action: 'edit'
        }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  # GET /projects/1/edit_project_permissions
  def edit_project_permissions
  end

  # PATCH/PUT /projects/1/update_project_permissions
  def update_project_permissions
    if @project.update(project_params)
      redirect_to edit_project_permissions_project_path(@project), notice: 'Your changes have been saved.'
    else
      render action: 'edit_project_permissions'
    end
  end

  # GET /projects/1/edit_enabled_dynamic_fields/1
  def edit_enabled_dynamic_fields
    @digital_object_type = DigitalObjectType.find(params[:digital_object_type_id])
  end

  # PATCH/PUT /projects/1/updated_enabled_dynamic_fields/1
  def update_enabled_dynamic_fields

    if @project.update(project_params)
      redirect_to edit_enabled_dynamic_fields_project_path(@project, params[:digital_object_type_id]), notice: 'Your changes have been saved.'
    else
      render action: 'edit_enabled_dynamic_fields'
    end
  end

  # GET /projects/1/fieldsets
  def fieldsets
    @fieldsets = Fieldset.where(project: @project)
  end

  # GET /projects/where_current_user_can_create
  def where_current_user_can_create
    respond_to do |format|
      format.json {
        if current_user.is_admin?
          projects = Project.all
        else
          projects = Project.includes(:project_permissions).joins(:project_permissions).where('project_permissions.user_id' => current_user.id, 'project_permissions.can_create' => true)
        end
        projects_with_enabled_digital_object_types = projects.map{|project|
          {string_key: project.string_key, display_label: project.display_label, enabled_digital_object_types:
            project.enabled_digital_object_types.map{|digital_object_type|{display_label: digital_object_type.display_label, string_key: digital_object_type.string_key}}
          }
        }
        render json: projects_with_enabled_digital_object_types
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(
      :id, :display_label, :string_key, :pid_generator_id, :full_path_to_custom_asset_directory,
      :enabled_dynamic_fields_attributes => [ :id, :digital_object_type_id, :dynamic_field_id, :default_value, :required, :hidden, :locked, :_destroy, :fieldset_ids => [] ],
      #:project_external_data_sources_attributes => [:id, :project_id, :external_data_source_id, :_destroy,
      #  :externally_synced_dynamic_fields_attributes => [:id, :project_external_data_source_id, :dynamic_field_id, :_destroy]
      #],
      :project_permissions_attributes => [:id, :_destroy, :user_id, :can_create, :can_read, :can_update, :can_delete, :is_project_admin],
      :fieldset_attributes => [:display_label, :project_id]
    )
  end

  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Projects'.html_safe
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Projects'.html_safe
      @contextual_nav_options['nav_title']['url'] = projects_path
    end



    case params[:action]
    when 'index'
      @contextual_nav_options['nav_items'].push(label: 'Add New Project', url: new_project_path) if current_user.is_admin?
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This Project', url: project_path(@project.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Project?' } }) if current_user.is_admin? and @project.string_key != 'publish_targets'
    when 'fieldsets'
      @contextual_nav_options['nav_items'].push(label: 'New Fieldset', url: new_fieldset_path(project_id: @project.id))
    end

  end

  def require_appropriate_permissions!

    case params[:action]
    when 'where_current_user_can_create'
        # Do nothing
    when 'index'
      unless current_user.is_project_admin_for_at_least_one_project?
        require_hyacinth_admin!
      end
    when 'edit', 'update', 'destroy',
      'edit_project_permissions', 'update_project_permissions',
      'edit_enabled_dynamic_fields', 'update_enabled_dynamic_fields', 'fieldsets'
      require_project_permission!(@project, :admin)
    else
      require_hyacinth_admin!
    end

  end
end
