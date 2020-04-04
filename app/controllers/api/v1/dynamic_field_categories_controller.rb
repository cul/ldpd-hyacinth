# frozen_string_literal: true

module Api
  module V1
    class DynamicFieldCategoriesController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource

      #  GET /dynamic_field_categories
      def index
        @dynamic_field_categories = DynamicFieldCategory.where(metadata_form: :descriptive).order(:sort_order)
        render json: { dynamic_field_categories: @dynamic_field_categories }, status: :ok
      end

      private

        def dynamic_field_category_params
          params.require(:dynamic_field_category).permit(:display_label, :sort_order)
        end
    end
  end
end
