class AssignmentsController < ApplicationController
  # GET /assignments
  def index
    @assignments = Assignment.where(assignee: current_user)
    @assignations = Assignment.where(assigner: current_user)
  end

  # GET /assignments/new
  def new
    @digital_object_record = DigitalObjectRecord.find_by(pid: params[:assignment][:digital_object_record_id])
    @assignment = Assignment.new(assignment_params.merge(assigner: current_user, digital_object_record: @digital_object_record))
  end

  # POST /assignments
  def create
    puts params.inspect
    puts assignment_params.inspect
    # use an id-based find is this is a numeric id, otherwise use the pid
    dor_key = assignment_params[:digital_object_record_id].to_s =~ /^\d+$/ ? :id : :pid
    @digital_object_record = DigitalObjectRecord.find_by(dor_key => assignment_params[:digital_object_record_id])
    digital_object = DigitalObject::Base.find(@digital_object_record.pid)
    @assignment = Assignment.new(assignment_params)
    @assignment.assigner = current_user
    # use raw params since assignee_email is not the foreign key
    @assignment.assignee = User.find_by(email: params[:assignment][:assignee_email])
    @assignment.digital_object_record = @digital_object_record
    @assignment.project = digital_object.project
    require_appropriate_project_permissions!
    @assignment.status = 'unassigned' unless @assignment.assignee.present?
    respond_to do |format|
      begin
        if @assignment.save
          format.html { redirect_to @assignment, locals: { notice: 'Assignment was successfully created.' } }
          format.json { render action: 'show', status: :created, location: @assignment }
        else
          format.html { render action: 'new', locals: { notice: "Could not save assignment." } }
          format.json { render json: @assignment.errors, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique
        format.html { render action: 'new', locals: { notice: "Task can only be assigned once for an object." } }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /assignments/$id
  def show
    @assignment = Assignment.find(params['id'])
  end

  # GET /assignments/$id/edit
  def edit
    @assignment = Assignment.find(params['id'])
  end

  # DELETE /assignments/$id
  def destroy
    @assignment = Assignment.find(params['id'])
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
    @assignment = Assignment.find(params['id'])
    unless params['status'] == 'in_progress' && @assignment.assignee == current_user
      require_appropriate_project_permissions!
    end
    @assignment.status = params[:assignment][:status].to_i
    @assignment.status = :unassigned if @assignment.assignee.blank?
    respond_to do |format|
      if (argument_error = status_update_error)
        format.html { render action: 'edit', locals: { notice: argument_error } }
        format.json { render json: { status: argument_error }, status: :unprocessable_entity }
      elsif @assignment.save
        format.html { redirect_to @assignment, locals: { notice: 'Assignment was successfully created.' } }
        format.json { render action: 'show', status: :created, location: @assignment }
      else
        format.html { render action: 'edit', locals: { notice: "Could not save assignment." } }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /assignments/$id/commit
  def commit
  end

  # whitelist attribute params for an assignment
  def assignment_params
    params.require(:assignment).permit(:task, :status, :project, :digital_object_record_id)
      .transform_values { |x| x =~ /\d+/ ? x.to_i : x }
  end

  def status_update_error
    steps = (Assignment.statuses[@assignment.status] - assignment_params[:status]).abs
    if  steps > 1
      status_label = Assignment.statuses.find { |k, v| v == assignment_params[:status] }.first
      "Workflow status can only change incrementally (#{@assignment.status} to #{status_label} is #{steps} steps)"
    end
  end

  private
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
end
