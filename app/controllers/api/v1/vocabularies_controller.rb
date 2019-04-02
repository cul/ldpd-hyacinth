module Api
  module V1
    class VocabulariesController < ApplicationApiController
      before_action :ensure_json_request, :require_vocabulary_manager!

      # GET /vocabularies
      def index
        search_parameters = params.to_unsafe_h.except(:action, :controller, :format)

        response = URIService.connection.vocabularies(search_parameters)
        render json: response.data, status: response.status
      end

      # GET /vocabularies/:string_key
      def show
        response = URIService.connection.vocabulary(params[:string_key])
        render json: response.data, status: response.status
      end

      # POST /vocabualaries
      def create
        response = URIService.connection.create_vocabulary(request_data)
        render json: { vocabulary: response.data }, status: response.status
      end

      # PATCH /vocabularies/:string_key
      def update
        response = URIService.connection.update_vocabulary(request_data)
        render json: { vocabulary: response.data }, status: response.status
      end

      # DELETE /vocabularies/:string_key
      def destroy
        response = URIService.connection.delete_vocabulary(params[:string_key])
        render json: response.data, status: response.status
      end

      protected

        def request_data
          params[:vocabulary].to_unsafe_h.tap do |hash|
            hash[:string_key] = params[:string_key] if params.key?(:string_key)
          end
        end
    end
  end
end
