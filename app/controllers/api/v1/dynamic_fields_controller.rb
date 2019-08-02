module Api
  module V1
    class DynamicFieldsController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource

      # GET /dynamic_fields/:id
      def show
        render json: { dynamic_field: @dynamic_field }, status: :ok
      end

      # POST /dynamic_fields
      def create
        @dynamic_field.created_by = current_user
        @dynamic_field.updated_by = current_user

        if @dynamic_field.save
          render json: { dynamic_field: @dynamic_field }, status: :created
        else
          render json: errors(@dynamic_field.errors.full_messages), status: :bad_request
        end
      end

      # PATCH /dynamic_fields/:id
      def update
        @dynamic_field.updated_by = current_user

        if @dynamic_field.update(update_params)
          render json: { dynamic_field: @dynamic_field }, status: :ok
        else
          render json: errors(@dynamic_field.errors.full_messages), status: :bad_request
        end
      end

      # DELETE /dynamic_fields/:id
      def destroy
        if @dynamic_field.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :bad_request
        end
      end

      private

        def create_params
          params.require(:dynamic_field).permit(
            :string_key, :display_label, :field_type, :sort_order, :is_facetable, :filter_label,
            :controlled_vocabulary, :select_options, :is_keyword_searchable, :is_title_searchable,
            :is_identifier_searchable, :dynamic_field_group_id
          )
        end

        def update_params
          params.require(:dynamic_field).permit(
            :display_label, :field_type, :sort_order, :is_facetable, :filter_label,
            :controlled_vocabulary, :select_options, :is_keyword_searchable, :is_title_searchable,
            :is_identifier_searchable
          )
        end
    end
  end
end
