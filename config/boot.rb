# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# TODO: remove this middleware when we can run off Rack >= 2.0.4 (> 2.0.3)
class MultipartBufferSizeOverride
  def initialize(app)
    @app = app
  end

  def call(env)
    # override the 16k multipart buffer size (Rack::Multipart::Parser::BUFSIZE)
    # with a 1m buffer for multipart
    env.merge!('rack.multipart.buffer_size' => 1_048_576)
    @app.call(env)
  end
end
