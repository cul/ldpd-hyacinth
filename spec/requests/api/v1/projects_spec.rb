# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects Requests', type: :request do
  describe 'GET /api/v1/projects/:string_key' do
    let(:project) { FactoryBot.create(:project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/projects/#{project.string_key}" }
    end

    context 'when logged in user has appropriate permissions' do
      context 'when string_key is valid' do
        before do
          sign_in_project_contributor to: :read_objects, project: project
          get "/api/v1/projects/#{project.string_key}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "project": {
              "display_label": "Great Project",
              "is_primary": true,
              "project_url": "https://example.com/great_project",
              "string_key": "great_project"
            }
          }))
        end
      end

      context 'when string_key is invalid' do
        before { get '/api/v1/projects/test-string-key' }

        it 'returns 404' do
          expect(response.status).to be 404
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            { "errors": [{ "title": "Not Found" }] }
          ))
        end
      end
    end
  end
end
