class Api::V2::ProjectsController < Api::V2::BaseController
  # GET /api/v2/projects
  # Returns all projects (for admins) or projects user has any permission for
  def index
    if current_user.admin?
      projects = Project.all.order(:display_label)
    else
      # Users can see projects they have any permission for
      project_ids = current_user.project_permissions.pluck(:project_id)
      projects = Project.where(id: project_ids).order(:display_label)
    end

    render json: { 
      projects: projects.map { |project| project_json(project) }
    }, status: :ok
  end

  private

  def project_json(project)
    {
      id: project.id,
      stringKey: project.string_key,
      displayLabel: project.display_label,
      pid: project.pid
    }
  end
end