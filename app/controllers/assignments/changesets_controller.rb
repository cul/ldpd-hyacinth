class Assignments::ChangesetsController < ApplicationController
  before_action :set_assignment, only: [:update, :proposed]

  def proposed
    render text: @assignment.proposed.present? ? @assignment.proposed : ''
  end

  # PUT /assignments/1/changeset
  def update
    digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
    render_unauthorized! && return unless assignee_for_type?(digital_object, @assignment.task)

    case @assignment.task
    # TODO: Add 'describe', 'annotate', and 'sequence' types to case statement
    when 'transcribe'
      form_object = Hyacinth::FormObjects::TranscriptUpdateFormObject.new(params)
      if form_object.errors.present?
        render json: {
          success: false,
          errors: form_object.error_messages_without_error_keys
        }
        return
      end
      create_or_update_transcribe_changeset(@assignment, digital_object, form_object.transcript_content)
    end
    @assignment.save

    render json: {
      success: @assignment.errors.blank?,
      errors: @assignment.errors,
      original: @assignment.original,
      proposed: @assignment.proposed
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
end
