module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3 < Abstract
        REQUIRED_CONFIG_OPTS = [:url, :user, :password].freeze
        OPTIONAL_CONFIG_OPTS = [:pid_generator].freeze
        HYACINTH_CORE_DATASTREAM_NAME = 'hyacinth_data'.freeze

        delegate :client, to: :connection

        include AssignmentContext::Client

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
          # TODO: add rel as appropriate
          # serialize the other datastreams
          FieldExportProfile.all.each do |profile|
            xml_doc = digital_object.render_field_export(profile)
            unless xml_doc.blank?
              ensure_datastream(fedora_object, profile.name, mimeType: 'text/xml')
              fedora_object.datastreams[profile.name].content = xml_doc
            end
          end

          assign(Fedora3::CoreProperties).from(digital_object).to(fedora_object)

          fedora_object.save
        end

        def ensure_json_datastream(fedora_object, dsid, props = {})
          if fedora_object.datastreams[dsid].new?
            default_props = { blob: JSON.generate({}) }
            create_json_datastream(fedora_object, dsid, default_props.merge(props))
          end
        end

        def create_json_datastream(fedora_object, dsid, props = {})
          create_datastream(fedora_object, dsid, props.merge(mimeType: 'application/json'))
        end

        def ensure_datastream(fedora_object, dsid, props = {})
          default_props = { versionable: true }
          create_datastream(fedora_object, dsid, default_props.merge(props)) if fedora_object.datastreams[dsid].new?
        end

        def create_xml_datastream(fedora_object, dsid, props = {})
          create_datastream(fedora_object, dsid, props.merge(mimeType: 'text/xml'))
        end

        def create_datastream(fedora_object, dsid, props = {})
          default_props = {
            controlGroup: 'M', dsLabel: dsid
          }
          ds = fedora_object.datastreams[dsid]
          props = default_props.merge(props)
          ds.content = props.delete(:blob) if props[:blob]
          default_props.merge(props).each do |prop, value|
            ds.send "#{prop}=".to_sym, value
          end
        end
      end
    end
  end
end
