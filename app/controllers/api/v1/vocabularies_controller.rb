module Api
  module V1
    class VocabulariesController < ApplicationApiController
      before_action :ensure_json_request, :require_vocabulary_manager

      # GET /vocabularies
      def index
        response = URIService.connection.vocabularies(params)
        render json: response.data, status: response.status
      end

      # GET /vocabularies/:string_key
      def show
        response = URIService.connection.vocabulary(params[:string_key])
        render json: response.data, status: response.status
      end

      # POST /vocabualaries
      def create
        response = URIService.connection.create_vocabulary(params[:vocabulary])
        render json: { vocabulary: response.data }, status: response.status
      end

      # PATCH /vocabularies/:string_key
      def update
        request_data = params[:vocabulary]
        request_data[:string_key] = params[:string_key]

        response = URIService.connection.update_vocabulary(request_data)
        render json: { vocabulary: response.data }, status: response.status
      end

      # DELETE /vocabularies/:string_key
      def destroy
        response = URIService.connection.delete_vocabulary(params[:string_key])
        render json: response.data, status: response.status
      end
    end
  end
end
