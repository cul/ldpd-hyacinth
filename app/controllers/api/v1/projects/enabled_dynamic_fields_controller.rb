# frozen_string_literal: true

module Api
  module V1
    module Projects
      class EnabledDynamicFieldsController < ApplicationApiController
        before_action :ensure_json_request

        load_resource :project, find_by: :string_key, id_param: :project_string_key
        before_action :authorize_project

        # GET /projects/:string_key/enabled_dynamic_fields/:digital_object_type
        def show
          render json: { enabled_dynamic_fields: enabled_dynamic_fields }, status: :ok
        end

        # PATCH /projects/:string_key/enabled_dynamic_fields/:digital_object_type
        def update
          enabled_dynamic_fields = update_params.to_h['enabled_dynamic_fields']
          enabled_dynamic_fields.each do |h|
            h['digital_object_type'] = params[:digital_object_type]
          end

          updated_enabled_dynamic_fields = {
            enabled_dynamic_fields_attributes: enabled_dynamic_fields
          }

          if @project.update(updated_enabled_dynamic_fields)
            render json: { enabled_dynamic_fields: enabled_dynamic_fields(reload: true) }, status: :ok
          else
            render json: errors(@project.errors.full_messages), status: :bad_request
          end
        end

        private

          def enabled_dynamic_fields(reload: false)
            @project.reload if reload
            @project.enabled_dynamic_fields.where(digital_object_type: params[:digital_object_type])
          end

          def update_params
            params.permit(
              enabled_dynamic_fields: [
                :id, :dynamic_field_id, :required, :locked, :hidden, :owner_only, :shareable, :default_value, :_destroy, field_set_ids: []
              ]
            )
          end

          # Need to authorize resource by action, by default only checks that user can read parent.
          def authorize_project
            authorize! action_name.to_sym, @project
          end
      end
    end
  end
end
