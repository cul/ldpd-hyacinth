class Assignments::ChangesetsController < ApplicationController
  #before_action :set_assignment, only: [:update]

  # PUT /assignments/1/changeset
  def update
    digital_object = DigitalObject::Base.find(@assignment.digital_object_pid)
    render_unauthorized! unless assignee_for_type?(digital_object, params[:type])

    case params[:type]
    # TODO: Add 'describe', 'annotate', and 'sequence' types to case statement
    when 'transcribe'
      errors = []
      if params[:file].present?
        if (errors = validate_transcript_upload_file(params[:file])).present?
          render json: {
            success: false,
            errors: errors
          }
          return
        end
        create_or_update_transcribe_changeset(@assignment, digital_object, params[:file].tempfile.read)
      elsif
        create_or_update_transcribe_changeset(@assignment, digital_object, params[:transcript_text])
      end
    end
    @assignment.save

    render json: {
      success: @assignment.errors.blank?,
      errors: @assignment.errors
    }
  end

  def show
  end

  def update
  end

  def destroy
  end

  private

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def create_or_update_transcribe_changeset(assignment, digital_object, new_content)
      assignment.original = digital_object.transcription if assignment.original.nil?
      assignment.proposed = new_content
    end
end
