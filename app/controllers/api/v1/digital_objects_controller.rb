module Api
  module V1
    class DigitalObjectsController < ApplicationApiController
      before_action :ensure_json_request
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

      # POST /digital_objects
      # POST /digital_objects.json
      def create
        digital_object_data = JSON.parse(create_or_update_params['digital_object_data_json'])
        @digital_object = DigitalObject::Base.class_for_type(digital_object_data['digital_object_type']).new
        @digital_object.set_digital_object_data(digital_object_data)

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

      def preserve
        @digital_object = DigitalObject::Base.find(publish_params[:uid])
        if @digital_object.preserve
          render :show, status: :created, location: @digital_object
        else
          render json: @digital_object.errors, status: :unprocessable_entity
        end
      end

      # Publish the The publish action also preserves.
      def publish
        @digital_object = DigitalObject::Base.find(publish_params[:uid])

        # TODO: One day, if publish targets don't need to be saved in the
        # preservation system, we may want the publish method to accept
        # params like publish_to, unpublish_from, and republish. For now,
        # we assume that pending_publish_to and pending_publish_from have
        # been set by the save method.

        if @digital_object.preserve && @digital_object.publish
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
        def set_digital_object
          @digital_object = DigitalObject::Base.find(params[:uid])
        end

        def create_or_update_params
          params.require(:digital_object).permit(:digital_object_data_json)
        end
    end
  end
end
