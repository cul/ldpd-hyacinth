module Api
  module V1
    module Vocabularies
      class CustomFieldsController < ApplicationApiController
        before_action :ensure_json_request
        authorize_resource class: false

        # GET /vocabularies/:vocabulary_string_key/custom_fields
        def create
          response = URIService.connection.create_custom_field(vocabulary, request_data)
          render json: { custom_field: response.data }, status: response.status
        end

        # GET /vocabularies/:vocabulary_string_key/custom_fields/:field_key
        def update
          response = URIService.connection.update_custom_field(vocabulary, request_data)
          render json: { custom_field: response.data }, status: response.status
        end

        # GET /vocabularies/:vocabulary_string_key/custom_fields/field_key
        def destroy
          response = URIService.connection.delete_custom_field(vocabulary, params[:field_key])
          render json: response.data, status: response.status
        end

        private

          def vocabulary
            params[:vocabulary_string_key]
          end

          def request_data
            params[:custom_field].to_unsafe_h.tap do |hash|
              hash[:field_key] = params[:field_key] if params.key?(:field_key)
            end
          end
      end
    end
  end
end
