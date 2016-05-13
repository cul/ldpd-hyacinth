module Projects
  class PermissionsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project
    before_action :require_appropriate_permissions!
    before_action :set_contextual_nav_options

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

    private

      def set_contextual_nav_options
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Projects'.html_safe
        @contextual_nav_options['nav_title']['url'] = projects_path
      end
  end
end
