module Projects
  class DynamicFieldsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project, only: [:show, :edit, :update, :destroy]

    def require_appropriate_permissions!

      case params[:action]
      when 'where_current_user_can_create'
          # Do nothing
      when 'index'
        unless current_user.is_project_admin_for_at_least_one_project?
          require_hyacinth_admin!
        end
      when 'edit', 'update', 'destroy'
        require_project_permission!(@project, :admin)
      else
        require_hyacinth_admin!
      end

    end

    # GET /projects/1/dynamic_fields/edit?digital_object_type_id=1
    def edit
      search_params
      @digital_object_type = DigitalObjectType.find(params[:digital_object_type_id])
    end

    # PATCH/PUT /projects/1/dynamic_fields?digital_object_type_id=1
    def update
      search_params
      if @project.update(project_params)
        redirect_to edit_enabled_dynamic_fields_path(id: @project.id), notice: 'Your changes have been saved.'
      else
        render action: 'edit'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:digital_object_type_id)
    end
  end
end