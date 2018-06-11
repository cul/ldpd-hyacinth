class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :create_changeset]
  before_action :set_contextual_nav_options

  # GET /assignments
  def index
    @assignments = Assignment.where(assignee: current_user)
    @assignations = Assignment.where(assigner: current_user)
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new(assignment_params.merge(assigner: current_user))
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)
    digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
    @assignment.project = digital_object.project
    @assignment.assigner ||= current_user
    @assignment.status = 'unassigned' unless @assignment.assignee.present?

    require_appropriate_project_permissions!

    begin
      successful_save = @assignment.save
    rescue ActiveRecord::RecordNotUnique
      @assignment.errors.add(:task, "Task can only be assigned once for an object.")
    end

    respond_to do |format|
      if successful_save
        format.html { redirect_to @assignment, locals: { notice: 'Assignment was successfully created.' } }
        format.json { render action: 'show', status: :created, location: @assignment }
      else
        format.html { render action: 'new', locals: { notice: "Could not save assignment." } }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /assignments/$id
  def show
  end

  # GET /assignments/$id/edit
  def edit
  end

  # DELETE /assignments/$id
  def destroy
    require_appropriate_project_permissions!
    respond_to do |format|
      if @assignment.destroy
        format.html { redirect_to assignments_path, notice: 'Assignment was successfully deleted.' }
        format.json { render action: 'index', status: :no_content, location: assignments_path }
      else
        format.html { render action: 'edit' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/$id
  # PATCH /assignments/$id
  def update
    require_appropriate_project_permissions!
    @assignment.status = :unassigned if @assignment.assignee.blank?

    respond_to do |format|
      if disallow_invaid_status_transitions(@assignment, assignment_params[:status]) && @assignment.update(assignment_params)
        format.html { render action: 'show', locals: { notice: 'Assignment was successfully updated.' } }
        format.json { render action: 'show', status: :ok, location: @assignment }
      else
        format.html { render action: 'edit', locals: { notice: "Could not save assignment." } }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /assignments/$id/commit
  def commit
  end

  def disallow_invaid_status_transitions(assignment, new_status)
    if (steps = (Assignment.statuses[assignment.status] - Assignment.statuses[new_status]).abs) > 1
      assignment.errors.add(:status, "Workflow status can only change incrementally (#{@assignment.status} to #{new_status} is #{steps} steps)")
      return false
    end
    true
  end

  def create_changeset
    create_sample_changeset
  end

  # TODO: This is just a sample action for demo-ing changesets
  def create_sample_changeset
    sample_data = {
      "dynamic_field_data" => {
        "title" => [
          {
            "title_sort_portion" => "175 Great Neck Rd."
          }
        ],
        "note" => [
          {
            "note_type" => "Date note",
            "note_value" => "Date range inferred from dates in the New York Real Estate Brochure Collection."
          },
          {
            "note_type" => "provenance",
            "note_value" => "Donated by Yale Robbins, Henry Robbins, & David Magier."
          }
        ]
      }
    }
    @assignment.original = JSON.pretty_generate(sample_data)
    sample_data['dynamic_field_data']['title'][0]['title_sort_portion'] = "175 Giraffe Neck Rd."
    sample_data['dynamic_field_data']['note'][0]['note_value'] = "Date range inferred from dates in the Bronx Zoo Brochure Collection."
    @assignment.proposed = JSON.pretty_generate(sample_data)
    @assignment.save
    redirect_to @assignment && return
  end

  private

    # whitelist attribute params for an assignment
    def assignment_params
      params.require(:assignment).permit(:task, :status, :project, :digital_object_pid, :assignee_id)
        .transform_values { |x| x =~ /^\d+$/ ? x.to_i : x }
    end

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def require_appropriate_project_permissions!
      case params[:action]
      when 'new', 'create', 'delete'
        require_project_permission!(@assignment.project, :project_admin)
      when 'new', 'create', 'edit', 'update', 'delete'
        unless @assignment.assignee == current_user
          require_project_permission!(@assignment.project, :project_admin)
        end
      when 'update'
        require_workflow_permission!(@assignment, params[:status].to_sym)
      else
        require_hyacinth_admin!
      end
    end

    def set_contextual_nav_options
      if params[:action] == 'index'
        @contextual_nav_options['nav_title']['label'] =  'Assignments'.html_safe
      else
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Assignments'.html_safe
        @contextual_nav_options['nav_title']['url'] = assignments_path
      end

      case params[:action]
      when 'show', 'update'
        @contextual_nav_options['nav_items'].push(label: 'Edit', url: edit_assignment_path(@assignment))
      end
    end
end
