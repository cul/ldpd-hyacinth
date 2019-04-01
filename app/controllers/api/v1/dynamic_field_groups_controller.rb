module Api
  module V1
    class DynamicFieldGroupsController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource

      # GET /dynamic_field_groups/:id
      def show
        render json: { dynamic_field_group: @dynamic_field_group }, status: :ok
      end

      # POST /dynamic_field_groups
      def create
        @dynamic_field_group.created_by = current_user
        @dynamic_field_group.updated_by = current_user

        if @dynamic_field_group.save
          render json: { dynamic_field_group: @dynamic_field_group }, status: :created
        else
          render json: errors(@dynamic_field_group.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /dynamic_field_groups/:id
      def update
        @dynamic_field_group.updated_by = current_user

        if @dynamic_field_group.update(update_params)
          render json: { dynamic_field_group: @dynamic_field_group }, status: :ok
        else
          render json: errors(@dynamic_field_group.errors.full_messages), status: :unprocessable_entity
        end
      end

      # DELETE /dynamic_field_groups/:id
      def destroy
        if @dynamic_field_group.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
        end
      end

      private

        def create_params
          params.require(:dynamic_field_group).permit(
            :string_key, :display_label, :sort_order, :is_repeatable, :xml_translation, :parent_type, :parent_id
          )
        end

        def update_params
          params.require(:dynamic_field_group).permit(
            :display_label, :is_repeatable, :xml_translation, :sort_order, :parent_type, :parent_id
          )
        end
    end
  end
end
