module Projects
  class PermissionsController < SubresourceController
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

    # GET /projects/1/permissions
    def show
    end

    # GET /projects/1/permissions/edit
    def edit
    end

    # PATCH/PUT /projects/1/permissions
    def update
      if @project.update(project_params)
        redirect_to edit_project_permissions_path(id: @project.id), notice: 'Your changes have been saved.'
      else
        render action: 'edit'
      end
    end
  end
end