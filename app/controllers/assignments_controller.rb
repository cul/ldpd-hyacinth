class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_assignment_from_create_params, only: [:create]
  before_action :require_appropriate_project_permissions!
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

  # GET /assignments/:id
  def show
  end

  # GET /assignments/:id/edit
  def edit
  end

  # DELETE /assignments/:id
  def destroy
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

  # PUT /assignments/:id
  # PATCH /assignments/:id
  def update
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

  # POST /assignments/:id/commit
  def commit
  end

  # POST /assignments/:id/reject
  def reject
  end

  def disallow_invaid_status_transitions(assignment, new_status)
    if (steps = (Assignment.statuses[assignment.status] - Assignment.statuses[new_status]).abs) > 1
      assignment.errors.add(:status, "Workflow status can only change incrementally (#{@assignment.status} to #{new_status} is a jump of #{steps} workflow steps)")
      return false
    end
    true
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

    def set_assignment_from_create_params
      @assignment = Assignment.new(assignment_params)
      digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
      @assignment.project = digital_object.project
      @assignment.assigner ||= current_user
      @assignment.status = 'unassigned' unless @assignment.assignee.present?

      # original and proposed fields should both be set upon assignment creation
      case @assignment.task
      # TODO: Add 'describe', 'annotate', and 'sequence' types to case statement
      when 'transcribe'
        # store current state of transcript in *original* field
        @assignment.original = digital_object.transcript || ''
        # also store current state of transcript in *proposed* field as starting point for editing
        @assignment.proposed = @assignment.original
      end
    end

    def require_appropriate_project_permissions!
      case params[:action]
      when 'new', 'create'
        require_project_permission!(@assignment.project, :project_admin)
      when 'update'
        unless @assignment.assignee == current_user
          require_project_permission!(@assignment.project, :project_admin)
        end
      when 'edit', 'destroy'
        unless @assignment.assigner == current_user
          require_project_permission!(@assignment.project, :project_admin)
        end
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
        if @assignment.assigner == current_user
          @contextual_nav_options['nav_items'].push(label: 'Edit', url: edit_assignment_path(@assignment))
          @contextual_nav_options['nav_items'].push(label: 'Delete', url: assignment_path(@assignment.id), options: { method: :delete, data: { confirm: 'Are you sure you want to delete this Assignment?' } })
        end
      end
    end
end
