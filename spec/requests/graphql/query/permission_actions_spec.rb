# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve permission actions', type: :request do
  context 'for any logged in user' do
    before do
      sign_in_user
      graphql query
    end

    it 'returns correct response' do
      expect(response.body).to be_json_eql(%({
        "permissionActions": {
          "projectActions": [
            "read_objects",
            "create_objects",
            "update_objects",
            "delete_objects",
            "publish_objects",
            "assess_rights",
            "manage"
          ]
        }
      })).at_path('data')
    end
  end

  def query
    <<~GQL
      query {
        permissionActions {
          projectActions
        }
      }
    GQL
  end
end
