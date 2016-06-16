module Projects
  class PublishTargetsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project, only: [:show, :edit, :update, :destroy]
    before_action :require_appropriate_permissions!
    before_action :set_contextual_nav_options

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

    private

      def set_contextual_nav_options
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Projects'.html_safe
        @contextual_nav_options['nav_title']['url'] = projects_path
      end
  end
end
