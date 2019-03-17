module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3 < Abstract
        REQUIRED_CONFIG_OPTS = [:url, :user, :password].freeze
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
          # TODO: (this is pseudocode) rubydora.exists?(location_uri_to_fedora3_pid(location_uri))
        end

        def persist_impl(location_uri, digital_object)
          # TODO
        end

        def location_uri_to_fedora3_pid(location_uri)
          location_uri.gsub(/^#{uri_prefix}/, '')
        end
      end
    end
  end
end
