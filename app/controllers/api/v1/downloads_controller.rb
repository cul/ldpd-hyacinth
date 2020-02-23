# frozen_string_literal: true

module Api
  module V1
    class DownloadsController < ApplicationApiController
      include ActionController::Live

      # If the buffer is too small it slows the download down, but if the buffer is too large it
      # ends up using a lot more memory and that memory usage seems to hang around longer.
      DOWNLOAD_BUFFER_BYTE_SIZE = 5.megabytes

      before_action :authorize_and_load!, only: [:download]

      # GET /api/v1/downloads/:type/:id/:subresource
      def download
        set_download_headers(response, @last_modified_datetime, @content_type, @size, @file_name)
        @storage.with_readable(@location) do |io|
          while (chunk = io.read(DOWNLOAD_BUFFER_BYTE_SIZE))
            response.stream.write(chunk)
          end
        ensure
          response.stream.close
        end
      end

      private

        def download_params
          params.permit(:type, :id, :subresource)
        end

        # Authorizes the requested resource and sets the following instance variables:
        # @storage, @location, @last_modified_datetime, @content_type, @size, @file_name
        # @return [void]
        def authorize_and_load!
          type = download_params[:type]
          id = download_params[:id]
          subresource = download_params[:subresource] # nil for some types

          case type
          when 'digital_object'
            authorize_and_load_digital_object_resource!(id, subresource)
          when 'batch_export'
            authorize_and_load_batch_export!(id)
          else
            raise Hyacinth::Exceptions::NotFound, "Could not find download with type #{type} and id #{id}"
          end
        end

        def authorize_and_load_batch_export!(id)
          batch_export = BatchExport.find(id)
          authorize! :read, batch_export
          file_location = batch_export.file_location
          raise Hyacinth::Exceptions::NotFound if file_location.blank?

          # Set required instance variables
          @storage = Hyacinth::Config.batch_export_storage
          @location = file_location
          @last_modified_datetime = batch_export.updated_at
          @content_type = 'text/csv'
          @size = @storage.size(file_location).to_s
          @file_name = "export-#{id}.csv"
        end

        # Authorizes the requested resource and sets the following instance variables:
        # @storage, @location, @last_modified_datetime, @content_type, @size, @file_name
        # @return [void]
        def authorize_and_load_digital_object_resource!(id, subresource)
          digital_object = DigitalObject::Base.find(id)
          authorize! :read, digital_object
          resource = digital_object.resources[subresource]
          raise Hyacinth::Exceptions::NotFound if resource.nil? || resource.location.blank?

          # Set required instance variables
          @storage = Hyacinth::Config.resource_storage
          @location = resource.location
          @last_modified_datetime = digital_object.updated_at
          @content_type = resource.media_type
          @size = resource.file_size.to_s
          @file_name = resource.original_filename
        end

        def set_download_headers(response, last_modified_datetime, content_type, size, file_name)
          response.headers["Last-Modified"] = last_modified_datetime.httpdate
          response.headers["Content-Type"] = content_type
          response.headers["Content-Disposition"] = label_to_content_disposition(file_name, true)
          response.headers["Content-Length"] = size.to_s
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
