module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
      before_action :load_resource, only: [:show, :edit, :update, :destroy, :preserve, :publish]
      authorize_resource :digital_object, only: [:show, :edit, :update, :destroy, :preserve, :publish]

      # GET /digital_objects/search
      # GET /digital_objects/search.json
      def search
        @digital_objects = DigitalObjectRecord.all
        render json: {
          digital_objects: @digital_objects
        }
      end

      # GET /digital_objects/1
      # GET /digital_objects/1.json
      def show
        render json: { digital_object: @digital_object }
      end

      # POST /digital_objects
      # POST /digital_objects.json
      def create
        digital_object_data = create_or_update_params
        digital_object_record = DigitalObjectRecord.create
        @digital_object = DigitalObject::Base.from_serialized_form(digital_object_record, digital_object_data)
        @digital_object.projects.each do |project|
          authorize! :create_objects, project
        end
        @digital_object.state ||= Hyacinth::DigitalObject::State::ACTIVE
        # digital_object_record.save first because it will assign necessary digital_object_record attributes
        if @digital_object.save(update_index: true) && (digital_object_record.persisted? || digital_object_record.save)
          show
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /digital_objects/1
      # PATCH/PUT /digital_objects/1.json
      def update
        digital_object_data = create_or_update_params
        @digital_object.set_digital_object_data(digital_object_data, true)

        update_result = @digital_object.save(update_index: true)
        update_result &&= publish if params[:publish].to_s.eql?('true')

        if update_result
          show
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      def preserve
        if @digital_object.preserve
          show
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # Publish the object. The publish action also preserves.
      def publish
        # TODO: One day, if publish targets don't need to be saved in the
        # preservation system, we may want the publish method to accept
        # params like publish_to, unpublish_from, and republish. For now,
        # we assume that pending_publish_to and pending_publish_from have
        # been set by the save method, or we are republishing all the existing targets.
        is_preserved = preserved? || @digital_object.preserve
        republish = (action_name.to_sym == :publish)
        @digital_object.set_pending_publish_entries('republish' => true) if republish
        if is_preserved && @digital_object.publish
          show if republish
          true
        else
          render json: @digital_object.errors, status: :unprocessable_entity if republish
          false
        end
      end

      # DELETE /digital_objects/1
      # DELETE /digital_objects/1.json
      def destroy
        @digital_object.projects.each do |project|
          authorize! :delete_objects, project
        end
        # TODO: un-preserve or tombstone
        # TODO: unindex and remove param?
        @digital_object.destroy(update_index: true)
        # unpublish
        @digital_object.publish
        head :no_content
      end

      def load_resource
        @digital_object ||= DigitalObject::Base.find(params[:id])
      end

      private
        def create_or_update_params
          # TODO: decide how we want to validate dynamic field data parameters
          params[:digital_object][:digital_object_data_json]&.permit!.to_h
        end

        def preserved?
          return false unless @digital_object.preserved_at.present?
          @digital_object.preserved_at > @digital_object.updated_at
        end
    end
  end
end
