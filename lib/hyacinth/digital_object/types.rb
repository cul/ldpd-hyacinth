# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    class Types
      attr_reader :keys

      def initialize(initial_keys_to_classes = {})
        @keys_to_classes = initial_keys_to_classes
        refresh_caches!
      end

      def register(key, klass)
        raise Hyacinth::Exceptions::DuplicateTypeError, "The key #{key} has already been registered. "\
          'Unregister the existing key and call register again if you wish to '\
          'replace it with a new mapping.' if @keys_to_classes.key?(key)
        @keys_to_classes[key] = klass
        refresh_caches!
      end

      def unregister(key)
        @keys_to_classes.delete(key)
        refresh_caches!
      end

      def refresh_caches!
        @classes_to_keys = @keys_to_classes.invert
        @keys = @keys_to_classes.keys
      end

      def include?(key)
        @keys_to_classes.key? key
      end

      def clear!
        @keys_to_classes = {}
        refresh_caches!
      end

      def key_to_display_label(key)
        key.camelize
      end

      def key_to_class(key)
        @keys_to_classes[key]
      end

      def class_to_key(klass)
        @classes_to_keys[klass]
      end
    end
  end
end
