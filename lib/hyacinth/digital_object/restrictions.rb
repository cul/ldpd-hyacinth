# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module Restrictions

      def self.included(base)
        base.extend ClassMethods
      end

      def restriction_attributes
        self.class.restriction_attributes
      end

      def restrictions
        @restrictions ||= restriction_attributes.map { |k, v| [k.to_s, v.default_value] }.to_h.with_indifferent_access
      end

      module ClassMethods
        def restriction_attributes
          @restriction_attributes ||= {} # initialized here because it may not have been initialized in a subclass of the including class
          if self.superclass.respond_to?(:restriction_attributes)
            @restriction_attributes.merge(self.superclass.restriction_attributes)
          else
            @restriction_attributes
          end
        end

        def restriction_attribute(restriction_attribute_name, type_def)
          @restriction_attributes ||= {}
          @restriction_attributes[restriction_attribute_name.to_sym] = type_def
        end
      end
    end
  end
end
