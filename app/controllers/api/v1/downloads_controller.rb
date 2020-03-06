# frozen_string_literal: true

module Api
  module V1
    class DownloadsController < ApplicationApiController
      include ActionController::Live

      # If the buffer is too small it slows the download down, but if the buffer is too large it
      # ends up using a lot more memory and that memory usage seems to hang around longer.
      DOWNLOAD_BUFFER_BYTE_SIZE = 5.megabytes

      # GET /downloads/digital_object/:id/:resource_name
      def digital_object
        id = digital_object_params[:id]
        resource_name = digital_object_params[:resource_name]

        digital_object = DigitalObject::Base.find(id)
        authorize! :read, digital_object
        resource = digital_object.resources[resource_name]
        raise Hyacinth::Exceptions::NotFound if resource.nil? || resource.location.blank?

        storage = Hyacinth::Config.resource_storage
        last_modified = digital_object.updated_at
        file_name = resource.original_filename

        set_download_headers(last_modified, resource.media_type, resource.file_size, file_name)
        download(storage, resource.location)
      end

      # GET /downloads/batch_export/:id
      def batch_export
        id = batch_export_params[:id]

        batch_export = BatchExport.find(id)
        authorize! :read, batch_export
        file_location = batch_export.file_location
        raise Hyacinth::Exceptions::NotFound if file_location.blank?

        storage = Hyacinth::Config.batch_export_storage
        last_modified = batch_export.updated_at
        size = storage.size(file_location).to_s

        set_download_headers(last_modified, 'text/csv', size, "export-#{id}.csv")
        download(storage, file_location)
      end

      private

        def digital_object_params
          params.permit(:id, :resource_name)
        end

        def batch_export_params
          params.permit(:id)
        end

        # File download.
        def download(storage, location)
          # TODO: Maybe support range requests in the future
          storage.with_readable(location) do |io|
            while (chunk = io.read(DOWNLOAD_BUFFER_BYTE_SIZE))
              response.stream.write(chunk)
            end
          ensure
            response.stream.close
          end
        end

        def set_download_headers(last_modified_datetime, content_type, size, file_name)
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
