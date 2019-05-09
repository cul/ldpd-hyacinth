module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
      before_action :load_resource, only: [:show, :edit, :update, :destroy, :preserve, :publish]
      authorize_resource :digital_object, only: [:show, :edit, :update, :destroy, :preserve, :publish]

      # GET /digital_objects/search
      # GET /digital_objects/search.json
      def search
        @digital_objects = DigitalObject.all
        render json: {
          results: @digital_objects
        }
      end

      # GET /digital_objects/1
      # GET /digital_objects/1.json
      def show
        render json: @digital_object
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
        if @digital_object.save && (digital_object_record.persisted? || digital_object_record.save)
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
        if @digital_object.save
          show
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      def preserve
        if @digital_object.preserve
          render :show, status: :created, location: @digital_object
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # Publish the The publish action also preserves.
      def publish
        # TODO: One day, if publish targets don't need to be saved in the
        # preservation system, we may want the publish method to accept
        # params like publish_to, unpublish_from, and republish. For now,
        # we assume that pending_publish_to and pending_publish_from have
        # been set by the save method.

        if @digital_object.preserve && @digital_object.publish
          render :show, status: :ok, location: @digital_object
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # DELETE /digital_objects/1
      # DELETE /digital_objects/1.json
      # Unimplemented
      def destroy
        @digital_object.destroy
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
    end
  end
end
