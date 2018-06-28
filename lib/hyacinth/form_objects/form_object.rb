module Hyacinth
  module FormObjects
    class FormObject
      include ActiveModel::Model

      attr_reader :errors

      def initialize
        @errors = ActiveModel::Errors.new(self)
      end

      def error_messages_without_error_keys
        all_messages = []
        errors.each do |attribute_key, message|
          all_messages << message
        end
        all_messages
      end
    end
  end
end
