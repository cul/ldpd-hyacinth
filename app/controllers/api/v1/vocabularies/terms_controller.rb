module Api
  module V1
    module Vocabularies
      class TermsController < ApplicationApiController
        before_action :ensure_json_request
        before_action :user_signed_in?, only: [:index, :show, :create]
        before_action :require_vocabulary_manager, only: [:update, :destroy]

        # GET /vocabularies/:vocabulary_string_key/terms
        def index
          response = URIService.connection.search_terms(vocabulary, params[:term])
          render json: response.data, status: response.status
        end

        # GET /vocabularies/:vocabulary_string_key/terms/:uri
        def show
          response = URIService.connection.term(vocabulary, params[:uri])
          render json: { term: response.data }, status: response.status
        end

        # POST /vocabularies/:vocabulary_string_key/terms
        def create
          response = URIService.connection.create_term(vocabulary, params[:term])
          render json: { term: response.data }, status: response.status
        end

        # PATCH /vocabularies/:vocabulary_string_key/terms/:uri
        def update
          data = params[:term]
          data[:uri] = params[:uri]

          response = URIService.connection.update_term(vocabulary, data)
          render json: { term: response.data }, status: response.status
        end

        # DELETE /vocabularies/:vocabulary_string_key/terms/:uri
        def destroy
          response = URIService.connection.delete_term(vocabulary, params[:uri])
          render json: response.data, status: response.status
        end

        private

          def vocabulary
            params[:vocabulary_string_key]
          end
      end
    end
  end
end
