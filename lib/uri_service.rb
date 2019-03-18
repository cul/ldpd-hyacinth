module URIService
  thread_mattr_accessor :active_connection

  def self.connection
    self.active_connection = new_connection unless active_connection
    active_connection
  end

  def self.new_connection
    config = HYACINTH[:uri_service]

    raise Hyacinth::Exceptions::MissingRequiredOpt, 'URI Service credentials not provided' if config.nil?

    UriService::Client.connection(
      url: config[:url], api_key: config[:api_key]
    )
  end

  def self.config
    config = Hyacinth[:uri_service]

    if config.blank? && config[:url].blank? && config[:api_key]
      raise Hyacinth::Exceptions::MissingRequiredOpt, 'URI Service credentials not provided or incomplete'
    end

    config
  end
end
