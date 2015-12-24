module Projects
  class PublishTargetsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project, only: [:show, :edit, :update, :destroy]
    before_action :set_contextual_nav_options

    def require_appropriate_permissions!

      case params[:action]
      when 'index', 'show'
        unless current_user.is_project_admin_for_at_least_one_project?
          require_hyacinth_admin!
        end
      when 'edit', 'update', 'destroy'
        require_project_permission!(@project, :project_admin)
      else
        require_hyacinth_admin!
      end

    end

    # GET /projects/1/publish_targets/edit
    def edit
    end

    # PATCH/PUT /projects/1/publish_targets
    def update_publish_targets
      if @project.update(project_params)
        redirect_to edit_project_publish_targets_path(id: @project.id), notice: 'Your changes have been saved.'
      else
        render action: 'edit'
      end
    end

    # PATCH/PUT /projects/1/publish_targets
    def update
      if @project.update(project_params)
        redirect_to edit_project_publish_targets_path(id: @project.id), notice: 'Your changes have been saved.'
      else
        render action: 'edit'
      end
    end

    def set_contextual_nav_options
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Projects'.html_safe
      @contextual_nav_options['nav_title']['url'] = projects_path
    end
  end
end
