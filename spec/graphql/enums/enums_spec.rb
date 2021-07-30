# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Enums', type: :request do
  context 'enumValues formatting' do
    before { sign_in_user }
    let(:enum_array) { all_enums }
    it 'is upper case and replaces spaces with underscores' do
      enum_array.each do |enum_name|
        enum_values(enum_name).each do |ev|
          expect(ev['name']).to eq(Types::BaseEnum.str_to_gql_enum(ev['name']))
        end
      end
    end
  end

  def all_enums
    graphql type_query
    data = JSON.parse(response.body)
    enums = data['data']['__schema']['types']
    enum_array = []
    enums.map do |entry|
      enum_array << entry['name'] if entry['kind'] == 'ENUM'
    end
    enum_array
  end

  def enum_values(enum_name)
    graphql value_query(enum_name)
    JSON.parse(response.body)['data']['__type']['enumValues']
  end

  def type_query
    <<~GQL
    query {
      __schema {
        types
        {
          name,
          kind
        }
      }
    }
    GQL
  end

  def value_query(enum_name)
    <<~GQL
    query EnumerationValues {
      __type(name: "#{enum_name}") {
        kind
        name
        description
        enumValues {
          name
          description
        }
      }
    }
    GQL
  end
end
