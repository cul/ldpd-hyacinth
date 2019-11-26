# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::AssignmentContext
        module Client
          def assign(klass)
            Fedora3::AssignmentContext.new(klass)
          end

          def datastream_for(export_profile)
            Fedora3::AssignmentContext::DatastreamExportContextFactory.new(export_profile)
          end
        end

        def initialize(klass)
          @property_class = klass
        end

        def to(fedora_obj)
          Deferred.new(@property_class, fedora_obj)
        end

        def from(hyacinth_obj)
          @property_class.from(hyacinth_obj)
        end

        class DatastreamExportContext
          include Fedora3::DatastreamMethods

          def initialize(export_profile, hyacinth_obj)
            @export_profile = export_profile
            @hyacinth_obj = hyacinth_obj
          end

          def to(fedora_obj)
            xml_doc = @hyacinth_obj.render_field_export(@export_profile)
            return if xml_doc.blank?
            ensure_datastream(fedora_obj, @export_profile.name, mimeType: 'text/xml')
            fedora_obj.datastreams[@export_profile.name].content = xml_doc
          end
        end

        class DatastreamExportContextFactory
          def initialize(export_profile)
            @export_profile = export_profile
          end

          def from(hyacinth_obj)
            Fedora3::AssignmentContext::DatastreamExportContext.new(@export_profile, hyacinth_obj)
          end

          def to(fedora_obj)
            Fedora3::AssignmentContext::Deferred.new(self, fedora_obj)
          end
        end

        class Deferred
          def initialize(klass, fedora_obj)
            @property_class = klass
            @fedora_obj = fedora_obj
          end

          def from(hyacinth_obj)
            @property_class.from(hyacinth_obj).to(@fedora_obj)
          end
        end
      end
    end
  end
end
