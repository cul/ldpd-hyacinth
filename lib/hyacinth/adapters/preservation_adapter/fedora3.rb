module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3 < Abstract
        REQUIRED_CONFIG_OPTS = [:url, :user, :password].freeze
        OPTIONAL_CONFIG_OPTS = [:pid_generator].freeze
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
          OPTIONAL_CONFIG_OPTS.each do |opt|
            self.instance_variable_set("@#{opt}", adapter_config[opt]) if adapter_config[opt].present?
          end
        end

        def uri_prefix
          "fedora3://"
        end

        # Generates a new persistence identifier, ensuring that no object exists for the new URI.
        # @return [String] a location uri
        def generate_new_location_uri
          candidate = uri_prefix + pid_generator.next_pid
          while exists?(candidate) do candidate = uri_prefix + pid_generator.next_pid; end
          candidate
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

        def pid_generator
          @pid_generator ||= PidGenerator.default_pid_generator
        end
      end
    end
  end
end
