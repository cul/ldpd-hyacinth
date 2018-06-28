class Assignments::ChangesetsController < ApplicationController
  before_action :set_assignment, only: [:update, :proposed]

  def proposed
    render text: @assignment.proposed.present? ? @assignment.proposed : ''
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcript_params
      params.permit(:file, :transcript_text)
    end
end
