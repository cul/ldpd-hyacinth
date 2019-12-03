# frozen_string_literal: true

module Api
  module V1
    class DynamicFieldCategoriesController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource

      #  GET /dynamic_field_categories
      def index
        @dynamic_field_categories = DynamicFieldCategory.order(:sort_order)
        render json: { dynamic_field_categories: @dynamic_field_categories }, status: :ok
      end

      # GET /dynamic_field_categories/:id
      def show
        render json: { dynamic_field_category: @dynamic_field_category }, status: :ok
      end

      # POST /dynamic_field_categories
      def create
        if @dynamic_field_category.save
          render json: { dynamic_field_category: @dynamic_field_category }, status: :created
        else
          render json: errors(@dynamic_field_category.errors.full_messages), status: :bad_request
        end
      end

      # PATCH /dynamic_field_categories/:id
      def update
        if @dynamic_field_category.update(dynamic_field_category_params)
          render json: { dynamic_field_category: @dynamic_field_category }, status: :ok
        else
          render json: errors(@dynamic_field_category.errors.full_messages), status: :bad_request
        end
      end

      # DELETE /dynamic_field_categories/:id
      def destroy
        if @dynamic_field_category.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :bad_request
        end
      end

      private

        def dynamic_field_category_params
          params.require(:dynamic_field_category).permit(:display_label, :sort_order)
        end
    end
  end
end
