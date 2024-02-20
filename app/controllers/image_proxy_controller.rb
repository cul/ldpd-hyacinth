class ImageProxyController < ApplicationController
  include ActionController::Live

  def raster
    remote_url = "#{IMAGE_SERVER_CONFIG[:url]}/iiif/2/#{params[:path]}.#{params[:format]}"
    uri = URI(remote_url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{IMAGE_SERVER_CONFIG[:token]}"

      http.request request do |remote_response|
        response.headers['Content-Length'] = remote_response['Content-Length']
        response.headers['Content-Type'] = remote_response['Content-Type']
        response.status = :ok

        remote_response.read_body do |chunk|
          response.stream.write chunk
        end
      end
    ensure
      response.stream.close
    end
  end
end
