# frozen_string_literal: true

module Types
  class BaseEnum < GraphQL::Schema::Enum
    def self.str_to_gql_enum(str)
      str.upcase.gsub(/\s+/, '_')
    end
  end
end
