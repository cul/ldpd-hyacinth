# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource find_by: :string_key, id_param: :string_key

      # GET /projects/:string_key
      def show
        if @project
          render json: { project: @project }, status: :ok
        else
          render json: errors('Not Found'), status: :not_found
        end
      end
    end
  end
end
