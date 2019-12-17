# frozen_string_literal: true

module Api
  module V1
    module DigitalObjects
      class RightsController < ApplicationApiController
        before_action :ensure_json_request
        before_action :load_resource, only: [:show, :edit, :update]

        # GET /digital_objects/1/rights
        # GET /digital_objects/1/rights.json
        def show
          authorize! :show, @digital_object
          render json: { digital_object: @digital_object }
        end

        # GET /digital_objects/1/rights/edit
        def edit
          authorize! :update_rights, @digital_object
        end

        # PATCH/PUT /digital_objects/1/rights
        # PATCH/PUT /digital_objects/1/rights.json
        def update
          authorize! :update_rights, @digital_object
          digital_object_rights_data = update_params
          if digital_object_rights_data[:rights]
            @digital_object.rights = digital_object_rights_data[:rights]
            update_result = @digital_object.save(update_index: true, user: current_user)
          end
          if update_result
            show
          else
            render json: @digital_object.errors, status: :bad_request
          end
        end

        def load_resource
          @digital_object ||= DigitalObject::Base.find(params[:id])
        end

        private

          def update_params
            # TODO: decide how we want to validate rights parameters
            params.require(:digital_object).permit(rights: {}).to_h
          end
      end
    end
  end
end
