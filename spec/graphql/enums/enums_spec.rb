# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Enums', type: :request do
  context 'enumValues formatting' do
    before { sign_in_user }
    it 'is upper case and replaces spaces with underscores' do
      graphql type_query
      data = JSON.parse(response.body)
      enums = data['data']['__schema']['types']
      enum_array = []
      enums.map do |entry|
        enum_array << entry['name'] if entry['kind'] == 'ENUM'
      end
      enum_array.each do |enum_name|
        graphql value_query(enum_name)
        enum_data = JSON.parse(response.body)
        enum_values = enum_data['data']['__type']['enumValues']
        enum_values.each do |ev|
          expect(ev['name']).to eq(ev['name'].upcase.tr(' ', '_'))
        end
      end
    end
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
