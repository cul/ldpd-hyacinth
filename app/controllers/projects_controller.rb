class ProjectsController < ApplicationController
  include Hyacinth::ProjectsBehavior
  before_action :set_project, only: [:show, :edit, :update, :destroy, :enabled_dynamic_fields, :edit_enabled_dynamic_fields,
                                     :update_enabled_dynamic_fields, :edit_project_permissions, :update_project_permissions,
                                     :fieldsets, :edit_publish_targets, :update_publish_targets,
                                     :select_dynamic_fields_for_csv_export, :select_dynamic_fields_csv_header_for_import,
                                     :upload_import_csv_file, :process_import_csv_file, :generate_csv_header_template]
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

  # TODO: Fold this into the :index view with a request param
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

  # GET /project/select_dynamic_fields_for_csv_export
  def select_dynamic_fields_for_csv_export
  end

  # GET /project/select_dynamic_fields_csv_header_for_import
  def select_dynamic_fields_csv_header_for_import

    # dynamic fields can be enabled for different digitial object types (item, asset, group) within a project
    # so a specific field may show up more than once in a query result which returns duplicates. We do not
    # want duplicates in our result set.
    @enabled_dynamic_fields_ids = @project.get_ids_of_dynamic_fields_that_are_enabled

    @enabled_dynamic_fields_csv_header = ::DynamicField.find(@enabled_dynamic_fields_ids)

  end

  # GET /projects/:id/generate_csv_header_template(.:format)
  def generate_csv_header_template

    array_headers =  Hyacinth::Utils::CsvHeaderTemplate.array_dynamic_field_headers @project.id
    csv_line = CSV::generate_line array_headers
    csv_filename = "#{@project.string_key}_header_template-#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.csv"
    # following sends csv data to browser for download
    send_data(csv_line, type: 'text/csv', filename: csv_filename)

  end

  private

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
      @contextual_nav_options['nav_items'].push(label: 'Delete This Project', url: project_path(@project.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Project?' } }) if current_user.is_admin?
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
      require_project_permission!(@project, :project_admin)
    else
      require_hyacinth_admin!
    end

  end
end
