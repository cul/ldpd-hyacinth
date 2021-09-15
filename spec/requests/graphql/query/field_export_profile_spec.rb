# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Field Export Profile', type: :request do
  let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query(field_export_profile.id) }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when id is valid' do
      let(:expected_response) do
        %(
           {
             "fieldExportProfile": {
               "name": "descMetadata",
               "translationLogic": "{\\n  \\"element\\": \\"mods:mods\\",\\n  \\"content\\": [\\n    {\\n      \\"yield\\": \\"name\\"\\n    }\\n  ]\\n}"
             }
           }
        )
      end
      before do
        graphql query(field_export_profile.id)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context 'when id is invalid' do
      before { graphql query('1234') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find FieldExportProfile with 'id'=1234"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(id)
    <<~GQL
      query {
        fieldExportProfile(id: "#{id}") {
          id
          name
          translationLogic
        }
      }
    GQL
  end
end
