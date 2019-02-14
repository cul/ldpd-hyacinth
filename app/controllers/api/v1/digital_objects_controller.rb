module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :set_digital_object, only: [:show, :edit, :update, :destroy]

      # GET /digital_objects/search
      # GET /digital_objects/search.json
      def search
        @digital_objects = DigitalObject.all
        render json: {
          results: @digital_objects
        }
      end

      # GET /digital_objects/1
      # GET /digital_objects/1.json
      def show
        render json: @digital_object
      end

      # GET /digital_objects/new
      def new
        @digital_object = DigitalObject::Base.class_for_type(new_params[:digital_object_type]).new
        render json: @digital_object
      end

      # GET /digital_objects/1/edit
      def edit
        render json: @digital_object
      end

      # POST /digital_objects
      # POST /digital_objects.json
      def create
        @digital_object = DigitalObject.new(digital_object_params)
        if @digital_object.save
          render :show, status: :created, location: @digital_object
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /digital_objects/1
      # PATCH/PUT /digital_objects/1.json
      def update
        if @digital_object.update(digital_object_params)
          render :show, status: :ok, location: @digital_object
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # DELETE /digital_objects/1
      # DELETE /digital_objects/1.json
      def destroy
        @digital_object.destroy
        head :no_content
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_digital_object
          @digital_object = DigitalObject.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def new_params
          params.permit(:digital_object_type)
        end
    end
  end
end
