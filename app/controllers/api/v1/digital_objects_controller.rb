# frozen_string_literal: true

module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
      before_action :load_resource, only: [:show]
      authorize_resource :digital_object, only: [:show]

      # GET /digital_objects/1
      # GET /digital_objects/1.json
      def show
        render json: { digital_object: @digital_object }
      end

      def load_resource
        @digital_object ||= DigitalObject.find_by_uid!(params[:id])
      end
    end
  end
end
