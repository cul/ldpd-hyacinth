# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object

    private
      def ability
        context[:ability]
      end
  end
end
