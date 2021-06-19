# frozen_string_literal: true

module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
      before_action :load_resource, only: [:show, :edit, :update, :destroy, :preserve, :publish]
      authorize_resource :digital_object, only: [:show, :edit, :update, :destroy, :preserve, :publish]

      # GET /digital_objects/1
      # GET /digital_objects/1.json
      def show
        render json: { digital_object: @digital_object }
      end

      def load_resource
        @digital_object ||= DigitalObject.find_by_uid!(params[:id])
      end

      # private
      # def preserved?
      #   return false unless @digital_object.preserved_at.present?
      #   @digital_object.preserved_at > @digital_object.updated_at
      # end
    end
  end
end
