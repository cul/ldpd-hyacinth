# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    include Types::Pageable

    private

      def ability
        context[:ability]
      end
  end
end
