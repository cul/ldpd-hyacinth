module URIService
  thread_mattr_accessor :active_connection

  def self.connection
    self.active_connection = new_connection unless active_connection
    active_connection
  end

  def self.new_connection
    config = Rails.application.config_for(:hyacinth)['uri_service']
    UriService::Client.connection(
      url: config['url'], api_key: config['api_key']
    )
  end
end
