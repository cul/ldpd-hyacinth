# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Field Export Profile', type: :request do
  before do
    FactoryBot.create(:field_export_profile)
    FactoryBot.create(:field_export_profile, name: 'rightsMetadata')
  end

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when there are multiple results' do
      let(:expected_response) do
        %(
          {
            "fieldExportProfiles": [
              {
                "name": "descMetadata",
                "translationLogic": "{\\n  \\"element\\": \\"mods:mods\\",\\n  \\"content\\": [\\n    {\\n      \\"yield\\": \\"name\\"\\n    }\\n  ]\\n}"
              },
              {
                "name": "rightsMetadata",
                "translationLogic": "{\\n  \\"element\\": \\"mods:mods\\",\\n  \\"content\\": [\\n    {\\n      \\"yield\\": \\"name\\"\\n    }\\n  ]\\n}"
              }
            ]
          }
        )
      end

      before { graphql query }

      it 'returns all field export profiles' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end
  end

  def query
    <<~GQL
      query {
        fieldExportProfiles {
          id
          name
          translationLogic
        }
      }
    GQL
  end
end
