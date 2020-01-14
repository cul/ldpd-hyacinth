# frozen_string_literal: true

module Api
  module V1
    module DigitalObjects
      # Because Rails 5 ActiveStorage does not export the BlobRecord class,
      # we must create the direct upload via REST. In Rails 6, the create logic
      # below could be moved into a GraphQL mutation, and the returned metadata used
      # to initiate the ActiveStorage upload.
      class UploadsController < ApplicationApiController
        before_action :ensure_json_request
        before_action :load_resource, only: [:create]

        # POST /digital_objects/1/uploads
        def create
          authorize! :update, @digital_object
          blob = ActiveStorage::Blob.create_before_direct_upload!(**create_params)

          # this is a development hack to alow us to get the path despite ActiveStorage's protests
          ActiveStorage::Current.host = 'stubhost'

          render json: blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
            url: blob.service_url_for_direct_upload.sub("http://#{ActiveStorage::Current.host}", ''),
            headers: blob.service_headers_for_direct_upload
          })
        end

        def load_resource
          @digital_object ||= DigitalObject::Base.find(params[:id])
        end

        private

          def create_params
            # TODO: decide how we want to validate rights parameters
            params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type, :metadata).to_h.symbolize_keys
          end
      end
    end
  end
end
