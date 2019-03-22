module Api
  module V1
    class ProjectsController < ApplicationApiController
      before_action :ensure_json_request

      load_resource find_by: :string_key, id_param: :string_key

      # GET /projects
      def index
        # TODO: restrict to only the projects a user has permissions to see
        # project_ids = Permission.where(group_id: current_user.group_ids, subject: Project.to_s).map(&:subject_id)
        # projects = Project.where(id: project_ids) # all projects you have access to

        projects = Project.all
        render json: { projects: projects }, status: :ok
      end

      # GET /projects/:string_key
      def show
        if @project
          render json: { project: @project }, status: :ok
        else
          render json: errors('Not Found'), status: :not_found
        end
      end

      # POST /projects
      def create
        if @project.save
          render json: { project: @project }, status: :created
        else
          render json: errors(@project.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /projects/:string_key
      def update
        if @project.update(update_params)
          render json: { project: @project }, status: :ok
        else
          render json: errors(@project.errors.full_messages), status: :unprocessable_entity
        end
      end

      # DELETE /projects/:string_key
      def destroy
        if @project.nil?
          render json: errors('Not Found'), status: :not_found
        elsif @project.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
        end
      end

      private

        def create_params
          params.require(:project).permit(:string_key, :display_label, :project_url)
        end

        def update_params
          params.require(:project).permit(:display_label, :project_url)
        end
    end
  end
end
