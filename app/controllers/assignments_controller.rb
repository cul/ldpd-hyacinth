class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :commit, :reject, :review]
  before_action :set_assignment_and_digital_object_from_new_or_create_params, only: [:new, :create]
  before_action :require_appropriate_project_permissions!
  before_action :set_contextual_nav_options

  # GET /assignments
  def index
    @assignments = Assignment.where(assignee: current_user)
    @assignations = Assignment.where(assigner: current_user)

    assignment_pids = (@assignments + @assignations).map{ |assignment| assignment.digital_object_pid }
    @pids_to_parent_pids = DigitalObject::Base.parent_pids_for_pids(assignment_pids, current_user)
    @pids_to_titles = DigitalObject::Base.titles_for_pids(
      assignment_pids + @pids_to_parent_pids.values.flatten.uniq.compact,
      current_user)
  end

  # GET /assignments/new
  def new
  end

  # POST /assignments
  def create
    @assignment.status = 'unassigned' if @assignment.assignee.blank?

    # original and proposed fields should both be set upon assignment creation
    case @assignment.task
    # TODO: Add 'sequence' type to case statement
    when 'transcribe'
      # store current state of transcript in *original* field
      @assignment.original = @digital_object.transcript || ''
      # also store current state of transcript in *proposed* field as starting point for editing
      @assignment.proposed = @assignment.original
    when 'annotate'
      # store current state of transcript in *original* field
      if @digital_object.audio_moving_image?
        @assignment.original = @digital_object.index_document
      else
        raise 'Not implemented yet'
      end
      # also store current state of transcript in *proposed* field as starting point for editing
      @assignment.proposed = @assignment.original
    when 'synchronize'
      # store current state of transcript in *original* field
      if @digital_object.audio_moving_image?
        @assignment.original = @digital_object.synchronized_transcript
      else
        raise 'Not implemented yet'
      end
      # also store current state of transcript in *proposed* field as starting point for editing
      @assignment.proposed = @assignment.original
    when 'describe'
      # store json version of current dynamic_field_data in *original* field
      @assignment.original = @digital_object.dynamic_field_data.to_json
      # also store json version of current dynamic_field_data in *proposed* field as starting point for editing
      @assignment.proposed = @assignment.original
    end

    begin
      # Don't allow existence of more than one assignment with the same type and pid
      successful_save = @assignment.save
    rescue ActiveRecord::RecordNotUnique
      @assignment.errors.add(:task, "can only be assigned once for an object.")
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
    @title_for_digital_object = DigitalObject::Base.title_for_pid(@assignment.digital_object_pid, current_user)
    @titles_for_parent_digital_objects = DigitalObject::Base.titles_for_pids(DigitalObject::Base.parent_pids_for_pid(@assignment.digital_object_pid, current_user), current_user)
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
    @assignment.status = 'unassigned' if @assignment.assignee.blank?

    respond_to do |format|
      if disallow_invaid_status_transitions(@assignment, assignment_params[:status]) && @assignment.update(assignment_params)
        format.html { redirect_to action: 'show', notice: 'Assignment was successfully updated.' }
        format.json { render action: 'show', status: :ok, location: @assignment }
      else
        format.html { render action: 'edit', locals: { notice: "Could not save assignment." } }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /assignments/:id/commit
  def commit
    digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)

    # TODO: Add 'sequence' type to case statement
    case @assignment.task
    when 'transcribe'
      digital_object.transcript = @assignment.proposed
    when 'annotate'
      # TODO: Probably change index_document to annotation
      if digital_object.audio_moving_image?
        digital_object.index_document = @assignment.proposed
      else
        raise 'Not implemented yet'
      end
    when 'synchronize'
      if digital_object.audio_moving_image?
        digital_object.synchronized_transcript = @assignment.proposed
      else
        raise "Cannot commit synchronized transcript for non-audiovisual resource (pid: #{digital_object.pid}, dc_type: #{digital_object.dc_type})"
      end
    when 'describe'
      digital_object.set_digital_object_data({'dynamic_field_data' => JSON.parse(@assignment.proposed)}, true)
    end

    Assignment.transaction do
      digital_object.save
      @assignment.status = 'accepted'
      ArchivedAssignment.from_assignment(@assignment).save!
      @assignment.destroy!
      redirect_to archived_assignment_path("ASSIGNMENT-#{@assignment.id}")
      return
    end
  end

  # GET /assignments/:id/reject
  def reject
  end

  # PUT /assignments/:id/review
  def review
    @assignment.update(status: 'in_review')
    redirect_to changeset_path(@assignment)
  end

  def disallow_invaid_status_transitions(assignment, new_status)
    return true if assignment.assigner == current_user # assigner can use assignment edit screen to change assignment to any state
    if (steps = (Assignment.statuses[assignment.status] - Assignment.statuses[new_status]).abs) > 1
      assignment.errors.add(:status, "Workflow status can only change incrementally (#{@assignment.status} to #{new_status} is a jump of #{steps} workflow steps)")
      return false
    end
    true
  end

  private

    # whitelist attribute params for an assignment
    def assignment_params
      params.require(:assignment).permit(:task, :status, :project, :note, :digital_object_pid, :assignee_id)
        .transform_values { |x| x =~ /^\d+$/ ? x.to_i : x }
    end

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_assignment_and_digital_object_from_new_or_create_params
      @assignment = Assignment.new(assignment_params)
      @digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
      @assignment.project = @digital_object.project
      @assignment.assigner ||= current_user
    end

    def require_appropriate_project_permissions!
      case params[:action]
      when 'new', 'create'
        require_project_permission!(@assignment.project, :project_admin)
      when 'update'
        unless @assignment.assignee == current_user || @assignment.assigner == current_user
          require_project_permission!(@assignment.project, :project_admin)
        end
      when 'edit', 'destroy', 'commit'
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
        if @assignment.assignee == current_user && ['assigned', 'in_progress'].include?(@assignment.status)
          @contextual_nav_options['nav_items'].push(label: 'Work On Assignment &raquo;'.html_safe, url: edit_changeset_path(@assignment))
        end
      when 'reject'
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Cancel'.html_safe
        @contextual_nav_options['nav_title']['url'] = assignment_path(@assignment)
      end
    end
end
