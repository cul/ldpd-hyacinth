module Api
  module V1
    module Projects
      class FieldSetsController < ApplicationApiController
        before_action :ensure_json_request

        load_resource :project, find_by: :string_key, id_param: :project_string_key
        load_resource :field_set, through: :project

        # GET /projects/:string_key/field_sets
        def index
          render json: { field_sets: @project.field_sets }, status: :ok
        end

        # GET /projects/:string_key/field_sets/:id
        def show
          render json: { field_set: @field_set }, status: :ok
        end

        # POST /projects/:string_key/field_sets
        def create
          if @field_set.save
            render json: { field_set: @field_set }, status: :created
          else
            render json: errors(@field_set.errors.full_messages), status: :unprocessable_entity
          end
        end

        # PATCH /projects/:string_key/fieldsets/:id
        def update
          if @field_set.update(field_set_params)
            render json: { fieldset: @field_set }, status: :ok
          else
            render json: errors(@field_set.errors.full_messages), status: :unprocessable_entity
          end
        end

        # DELETE /projects/:string_key/fieldsets/:id
        def destroy
          if @field_set.destroy
            head :no_content
          else
            render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
          end
        end

        private

          def field_set_params
            params.require(:field_set).permit(:display_label)
          end
      end
    end
  end
end
