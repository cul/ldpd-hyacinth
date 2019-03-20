module Api
  module V1
    module Projects
      class PublishTargetsController < ApplicationApiController
        load_resource :project, find_by: :string_key, id_param: :project_string_key
        load_resource :publish_target, find_by: :string_key, id_param: :string_key, through: :project

        # GET /projects/:string_key/publish_targets
        def index
          render json: { publish_targets: @project.publish_targets }, status: 200
        end

        # GET /projects/:string_key/publish_targets/:string_key
        def show
          render json: { publish_target: @publish_target }, status: 200
        end

        # POST /projects/:string_key/publish_targets
        def create
          if @publish_target.save
            render json: { publish_target: @publish_target }, status: :created
          else
            render json: errors(@publish_target.errors.full_messages), status: :unprocessable_entity
          end
        end

        # PATCH /projects/:string_key/publish_targets/:string_key
        def update
          if @publish_target.update(update_params)
            render json: { publish_target: @publish_target }, status: :ok
          else
            render json: errors(@publish_target.errors.full_messages), status: :unprocessable_entity
          end
        end

        # DELETE /projects/:string_key/publish_targets/:string_key
        def destroy
          if @publish_target.destroy
            head :no_content
          else
            render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
          end
        end

        private

          def create_params
            params.require(:publish_target).permit(:string_key, :display_label, :publish_url, :api_key)
          end

          def update_params
            params.require(:publish_target).permit(:display_label, :publish_url, :api_key)
          end
      end
    end
  end
end
