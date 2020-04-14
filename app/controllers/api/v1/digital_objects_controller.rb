# frozen_string_literal: true

module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
      before_action :load_resource, only: [:show, :edit, :update, :destroy, :preserve, :publish]
      authorize_resource :digital_object, only: [:show, :edit, :update, :destroy, :preserve, :publish]

      # GET /digital_objects/search
      # GET /digital_objects/search.json
      def search
        @digital_objects = DigitalObjectRecord.all.map do |dor|
          object = DigitalObject::Base.find(dor.uid)
          gql_compatibility_props = {
            'id' => dor.uid, 'title' => object.generate_title
          }
          object.as_json(except: ['digital_object_record']).merge(gql_compatibility_props)
        end
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
        @digital_object = Hyacinth::Config.digital_object_types.key_to_class(digital_object_data['digital_object_type']).new
        @digital_object.assign_attributes(digital_object_data)

        authorize! :create_objects, @digital_object.primary_project

        if @digital_object.save(update_index: true, user: current_user)
          show
        else
          render json: @digital_object.errors, status: :bad_request
        end
      end

      # PATCH/PUT /digital_objects/1
      # PATCH/PUT /digital_objects/1.json
      def update
        digital_object_data = create_or_update_params
        @digital_object.assign_attributes(digital_object_data)

        update_result = @digital_object.save(update_index: true, user: current_user)
        update_result &&= publish if params[:publish].to_s.eql?('true')

        if update_result
          show
        else
          render json: @digital_object.errors, status: :bad_request
        end
      end

      def preserve
        if @digital_object.preserve
          show
        else
          render json: @digital_object.errors, status: :bad_request
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
        @digital_object.assign_pending_publish_entries('republish' => true) if republish
        if is_preserved && @digital_object.publish
          show if republish
          true
        else
          render json: @digital_object.errors, status: :bad_request if republish
          false
        end
      end

      # DELETE /digital_objects/1
      # DELETE /digital_objects/1.json
      def destroy
        @digital_object.projects.each do |project|
          authorize! :delete_objects, project
        end
        @digital_object.destroy
        show
      end

      def load_resource
        @digital_object ||= DigitalObject::Base.find(params[:id])
      end

      private

        def create_or_update_params
          # TODO: decide how we want to validate dynamic field data parameters
          params.require(:digital_object).except(:rights)&.permit!.to_h
        end

        def preserved?
          return false unless @digital_object.preserved_at.present?
          @digital_object.preserved_at > @digital_object.updated_at
        end
    end
  end
end
