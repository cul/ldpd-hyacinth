module Api
  module V1
    module Vocabularies
      class TermsController < ApplicationApiController
        before_action :ensure_json_request
        before_action :require_authenticated_user!, only: [:index, :show, :create]
        before_action :require_vocabulary_manager!, only: [:update, :destroy]

        # GET /vocabularies/:vocabulary_string_key/terms
        def index
          search_parameters = params.to_unsafe_h
                                    .except(:action, :controller, :format, :vocabulary_string_key)

          response = URIService.connection.search_terms(vocabulary, search_parameters)
          render json: response.data, status: response.status
        end

        # GET /vocabularies/:vocabulary_string_key/terms/:uri
        def show
          response = URIService.connection.term(vocabulary, params[:uri])
          render json: { term: response.data }, status: response.status
        end

        # POST /vocabularies/:vocabulary_string_key/terms
        def create
          response = URIService.connection.create_term(vocabulary, request_data)
          render json: { term: response.data }, status: response.status
        end

        # PATCH /vocabularies/:vocabulary_string_key/terms/:uri
        def update
          response = URIService.connection.update_term(vocabulary, request_data)
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

          def request_data
            params[:term].to_unsafe_h.tap do |hash|
              hash[:uri] = params[:uri] if params.key?(:uri)
            end
          end

          def require_authenticated_user!
            raise CanCan::AccessDenied unless user_signed_in?
          end
      end
    end
  end
end
