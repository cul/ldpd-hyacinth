module Hyacinth
  module DigitalObject
    class Types

      attr_reader :keys

      def initialize
        @keys_to_classes = {}
        @classes_to_keys = {}
        @keys = []
      end

      def register(key, klass)
        @keys_to_classes[key] = klass
        refresh_caches!
      end

      def refresh_caches!
        @classes_to_keys = @keys_to_classes.invert
        @keys = @keys_to_classes.keys
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
