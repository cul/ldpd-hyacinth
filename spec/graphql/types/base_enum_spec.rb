# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::BaseEnum do
  context '.str_to_gql_enum' do
    {
      'abc' => 'ABC',
      'abc def' => 'ABC_DEF',
      'abc          def          g' => 'ABC_DEF_G',
      'abc_def' => 'ABC_DEF',
      'abc___def' => 'ABC___DEF'
    }.each do |str, str_formatted_as_gql_enum|
      it %(transforms "#{str}" into "#{str_formatted_as_gql_enum}") do
        expect(described_class.str_to_gql_enum(str)).to eq(str_formatted_as_gql_enum)
      end
    end
  end
end
