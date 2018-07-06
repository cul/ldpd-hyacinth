class ArchivedAssignmentsController < ApplicationController
  before_action :set_archived_assignment, only: [:show, :destroy]
  before_action :require_appropriate_project_permissions!
  before_action :set_contextual_nav_options

  # GET /archived_assignments
  def index
    @archived_assignments = ArchivedAssignment.all
  end

  # GET /archived_assignments/:id
  def show
  end


  # DELETE /archived_assignments/:id
  def destroy
    respond_to do |format|
      if @archived_assignment.destroy
        format.html { redirect_to archived_assignments_path, notice: 'Archived Assignment was successfully deleted.' }
        format.json { render action: 'index', status: :no_content, location: archived_assignments_path }
      else
        format.html { render action: 'edit' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_archived_assignment
      @archived_assignment = ArchivedAssignment.find_by(original_assignment_id: params[:id].gsub('ASSIGNMENT-', '').to_i)
    end

    def require_appropriate_project_permissions!
      case params[:action]
      when 'show', 'destroy'
        require_project_permission!(@archived_assignment.project, :project_admin)
      end
    end

    def set_contextual_nav_options
      if params[:action] == 'index'
        @contextual_nav_options['nav_title']['label'] =  'Archived Assignments'.html_safe
      else
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Archived Assignments'.html_safe
        @contextual_nav_options['nav_title']['url'] = archived_assignments_path
      end

      case params[:action]
      when 'show'
        if current_user.admin?
          @contextual_nav_options['nav_items'].push(label: 'Delete', url: archived_assignment_path(@archived_assignment.id), options: { method: :delete, data: { confirm: 'Are you sure you want to delete this Archived Assignment?' } })
        end
      end
    end
end
