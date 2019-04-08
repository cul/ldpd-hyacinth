module Api
  module V1
    class FieldExportProfilesController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource

      # GET /field_export_profiles
      def index
        field_export_profiles = FieldExportProfile.all
        render json: { field_export_profiles: field_export_profiles }, status: :ok
      end

      # GET /field_export_profiles/:id
      def show
        render json: { field_export_profile: @field_export_profile }, status: :ok
      end

      # POST /field_export_profiles
      def create
        if @field_export_profile.save
          render json: { field_export_profile: @field_export_profile }, status: :created
        else
          render json: errors(@field_export_profile.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /field_export_profiles/:id
      def update
        if @field_export_profile.update(field_export_profile_params)
          render json: { field_export_profile: @field_export_profile }, status: :ok
        else
          render json: errors(@field_export_profile.errors.full_messages), status: :unprocessable_entity
        end
      end

      # DELETE /field_export_profiles/:id
      def destroy
        if @field_export_profile.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
        end
      end

      private

        def field_export_profile_params
          params.require(:field_export_profile).permit(:name, :translation_logic)
        end
    end
  end
end
