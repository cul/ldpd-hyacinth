# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3 < Abstract
        REQUIRED_CONFIG_OPTS = [:url, :user, :password].freeze
        OPTIONAL_CONFIG_OPTS = [:pid_generator].freeze
        HYACINTH_CORE_DATASTREAM_NAME = 'hyacinth_data'

        delegate :client, to: :connection

        include DatastreamMethods
        include AssignmentContext::Client

        def self.uri_prefix
          @uri_prefix ||= "fedora3://"
        end

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
          Fedora3.uri_prefix
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

        def location_uri_to_fedora3_pid(location_uri)
          location_uri[(uri_prefix.length)..-1]
        end

        # @return [Rubydora::Repository] Fedora connection configured from adapter attributes
        def connection
          @connection ||= Rubydora.connect url: @url, user: @user, password: @password
        end

        def pid_generator
          @pid_generator ||= PidGenerator.default_pid_generator
        end

        def persist_impl(location_uri, digital_object)
          # get the Rubydora object
          fedora_object = connection.find_or_initialize(location_uri_to_fedora3_pid(location_uri))
          ensure_json_datastream(fedora_object, HYACINTH_CORE_DATASTREAM_NAME, versionable: true)
          # persist the digital object json
          fedora_object.datastreams[HYACINTH_CORE_DATASTREAM_NAME].content =
            JSON.generate(digital_object.to_serialized_form)
          # serialize the other datastreams
          FieldExportProfile.all.each do |profile|
            assign(datastream_for(profile)).from(digital_object).to(fedora_object)
          end

          assign(Fedora3::ObjectProperties).from(digital_object).to(fedora_object)
          assign(Fedora3::DcProperties).from(digital_object).to(fedora_object)
          assign(Fedora3::RelsExtProperties).from(digital_object).to(fedora_object)
          assign(Fedora3::RelsIntProperties).from(digital_object).to(fedora_object)
          assign(Fedora3::StructProperties).from(digital_object).to(fedora_object)

          fedora_object.save
        end
      end
    end
  end
end
