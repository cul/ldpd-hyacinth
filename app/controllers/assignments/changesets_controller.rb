class Assignments::ChangesetsController < ApplicationController
  before_action :set_assignment, only: [:update, :proposed, :edit, :update, :show]
  before_action :set_contextual_nav_options

  def proposed
    render text: @assignment.proposed.present? ? @assignment.proposed : @assignment.original
  end

  # GET /assignments/1/changeset/edit
  def edit
    @assignment.update(status: 'in_progress') if @assignment.status == 'assigned'
  end

  # GET /assignments/1/changeset
  def show
  end

  # PUT /assignments/1/changeset
  def update
    digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
    render_unauthorized! && return unless assignee_for_type?(digital_object, @assignment.task)

    # TODO: Add 'describe', 'annotate', and 'sequence' types to case statement
    case @assignment.task
    when 'transcribe'
      form_object = Hyacinth::FormObjects::TranscriptUpdateFormObject.new(transcript_params)
      if form_object.valid?
        create_or_update_transcribe_changeset(@assignment, digital_object, form_object.transcript_content)
        @assignment.save
      else
        render json: {
          success: false,
          errors: form_object.errors.full_messages
        }
        return
      end
    when 'annotate'
      if index_document_params[:index_document_text]
        if ['MovingImage', 'Sound'].include?(digital_object.dc_type)
          create_or_update_annotate_changeset(@assignment, digital_object, index_document_params[:index_document_text])
          @assignment.save
        else
          raise 'Not implemented yet'
        end
      end
    when 'synchronize'
      if index_document_params[:captions_text]
        if ['MovingImage', 'Sound'].include?(digital_object.dc_type)
          create_or_update_synchronize_changeset(@assignment, digital_object, captions_params[:captions_text])
          @assignment.save
        else
          raise 'Not implemented yet'
        end
      end
    end

    render json: {
      success: @assignment.errors.blank?,
      errors: @assignment.errors.full_messages
    }
  end

  private

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def create_or_update_transcribe_changeset(assignment, digital_object, new_content)
      assignment.original = digital_object.transcript if assignment.original.nil?
      assignment.proposed = new_content
    end

    def create_or_update_annotate_changeset(assignment, digital_object, new_content)
      if ['MovingImage', 'Sound'].include?(digital_object.dc_type)
        assignment.original = digital_object.index_document if assignment.original.nil?
      else
        raise 'Not implemented yet'
      end
      assignment.proposed = new_content
    end

    def create_or_update_synchronize_changeset(assignment, digital_object, new_content)
      if ['MovingImage', 'Sound'].include?(digital_object.dc_type)
        assignment.original = digital_object.captions if assignment.original.nil?
      else
        raise 'Not implemented yet'
      end
      assignment.proposed = new_content
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcript_params
      params.permit(:file, :transcript_text)
    end

    def index_document_params
      params.permit(:index_document_text)
    end

    def captions_params
      params.permit(:captions_params)
    end

    def set_contextual_nav_options
      case params[:action]
      when 'edit', 'update', 'show'
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Assignment'.html_safe
        @contextual_nav_options['nav_title']['url'] = assignment_path(@assignment)
      end
    end
end
