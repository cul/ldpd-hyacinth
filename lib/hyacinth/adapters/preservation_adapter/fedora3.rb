module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3 < Abstract
        REQUIRED_CONFIG_OPTS = [:url, :user, :password].freeze
        delegate :client, to: :connection
        def initialize(adapter_config = {})
          super(adapter_config)

          REQUIRED_CONFIG_OPTS.each do |required_opt|
            if adapter_config[required_opt].present?
              self.instance_variable_set("@#{required_opt}", adapter_config[required_opt])
            else
              raise Hyacinth::Exceptions::MissingRequiredOpt, "Missing required opt: #{required_opt}"
            end
          end
        end

        def uri_prefix
          "fedora3://"
        end

        # Generates a new persistence location for the given identifier, ensuring that nothing currently exists at that location.
        # @return [String] a location uri
        def generate_new_location_uri(identifier)
          # TODO
        end

        # Checks to see whether anything currently exists at the given location.
        # @return [boolean] true if something exists, false if nothing exists
        def exists?(location_uri)
          r = client[connection.api.object_url(location_uri_to_fedora3_pid(location_uri), format: 'xml')].head
          # without disabling redirection, we should not get 3xx here
          (200..299).cover? r.code
        rescue RestClient::ExceptionWithResponse => e
          return false if e.response.code.eql? 404
          raise e
        end

        def persist_impl(location_uri, digital_object)
          # TODO
        end

        def location_uri_to_fedora3_pid(location_uri)
          location_uri[(uri_prefix.length - 1)..-1]
        end

        # @return [Rubydora::Repository] Fedora connection configured from adapter attributes
        def connection
          @connection ||= Rubydora.connect url: @url, user: @user, password: @password
        end
      end
    end
  end
end
