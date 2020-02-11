# frozen_string_literal: true

module Api
  module V1
    module DigitalObjects
      class ResourcesController < ApplicationApiController
        include ActionController::Live

        # If the buffer is too small it slows the download down, but if the buffer is too large it
        # ends up using a lot more memory and that memory usage seems to hang around longer.
        DOWNLOAD_BUFFER_BYTE_SIZE = 5.megabytes

        before_action :load_resource, only: [:download]

        # GET /digital_objects/:id/resources/:resource_name/download
        def download
          authorize! :read, @digital_object
          set_download_headers(response, @digital_object, @resource)
          @resource.with_readable do |io|
            while (chunk = io.read(DOWNLOAD_BUFFER_BYTE_SIZE))
              response.stream.write(chunk)
            end
          ensure
            response.stream.close
          end
        end

        private

          def download_params
            params.permit(:id, :resource_name)
          end

          def load_resource
            @digital_object = DigitalObject::Base.find(params[:id])
            @resource_name = download_params[:resource_name]
            @resource = @digital_object.resources[@resource_name]
            raise Hyacinth::Exceptions::NotFound if @resource.nil? || @resource.location.blank?
          end

          def set_download_headers(response, digital_object, resource)
            response.headers["Last-Modified"] = digital_object.updated_at.httpdate
            response.headers["Content-Type"] = resource.media_type
            response.headers["Content-Disposition"] = label_to_content_disposition(resource.original_filename, true)
            response.headers["Content-Length"] = resource.file_size.to_s
            response.status = :ok
          end

          # Translate a label into a rfc5987 encoded header value
          # see also http://tools.ietf.org/html/rfc5987#section-4.1
          def label_to_content_disposition(label, attachment = false)
            safe_label = label.gsub(' ', '%20').gsub(',', '%2C')
            # The two adjacent single quotes in the line below look weird, but are correct:
            (attachment ? 'attachment; ' : 'inline') + "; filename*=utf-8''" + safe_label
          end
      end
    end
  end
end
