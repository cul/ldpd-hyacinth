# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects Requests', type: :request do
  describe 'GET /api/v1/projects' do
    include_examples 'requires user to have correct permissions' do
      let(:request) { get '/api/v1/projects' }
    end

    context 'when logged in user is an admin shows all projects' do
      describe 'when there are multiple results' do
        before do
          sign_in_user as: :administrator
          FactoryBot.create(:project)
          FactoryBot.create(:project, :legend_of_lincoln)
          get '/api/v1/projects'
        end

        it 'returns all projects' do
          expect(response.body).to be_json_eql(%(
            {
              "projects": [
                {
                  "display_label": "Great Project",
                  "is_primary": true,
                  "project_url": "https://example.com/great_project",
                  "string_key": "great_project"
                },
                {
                  "display_label": "Legend of Lincoln",
                  "is_primary": true,
                  "project_url": "https://example.com/legend_of_lincoln",
                  "string_key": "legend_of_lincoln"
                }
              ]
            }
          ))
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end
      end
    end

    context 'when logged-in user only has permissions to one project' do
      before do
        project = FactoryBot.create(:project)
        FactoryBot.create(:project, :legend_of_lincoln)
        sign_in_project_contributor to: :read_objects, project: project
        get '/api/v1/projects'
      end

      it 'returns 1 project' do
        expect(response.body).to be_json_eql(%(
          {
            "projects": [
              {
                "display_label": "Great Project",
                "is_primary": true,
                "project_url": "https://example.com/great_project",
                "string_key": "great_project"
              }
            ]
          }
        ))
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end
  end

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

  describe 'POST /api/v1/projects' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/projects', params: { project: { string_key: 'best_project' } }
      end
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'when creating a new project' do
        before do
          post '/api/v1/projects', params: {
            project: { string_key: 'best_project', display_label: 'Best Project', is_primary: true, project_url: 'https://best_project.com' }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "project": {
              "display_label": "Best Project",
              "is_primary": true,
              "project_url": "https://best_project.com",
              "string_key": "best_project"
            }
          }))
        end
      end

      context 'when create request is missing string_key' do
        before do
          post '/api/v1/projects', params: {
            project: { display_label: 'Best Project', project_url: 'https://best_project.com' }
          }
        end

        it 'returns 400' do
          expect(response.status).to be 400
        end

        it 'returns error' do
          expect(response.body).to be_json_eql(%({
            "errors": [
              { "title": "String key can't be blank" }
            ]
          }))
        end
      end

      context 'when create request is missing display_label' do
        before do
          post '/api/v1/projects', params: {
            project: { string_key: 'best_project', project_url: 'https://best_project.com' }
          }
        end

        it 'returns 400' do
          expect(response.status).to be 400
        end

        it 'returns error' do
          expect(response.body).to be_json_eql(%({
            "errors": [
              { "title": "Display label can't be blank" }
            ]
          }))
        end
      end
    end
  end

  describe 'PATCH /api/v1/projects/:string_key' do
    let(:project) { FactoryBot.create(:project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/projects/#{project.string_key}", params: { project: { display_label: 'Best Project' } }
      end
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_project_contributor to: :manage, project: project }

      context 'when updating record' do
        before do
          patch "/api/v1/projects/#{project.string_key}", params: {
            project: { display_label: 'Best Project', project_url: 'https://best_project.com' }
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          project.reload
          expect(project.display_label).to eql 'Best Project'
          expect(project.project_url).to eql 'https://best_project.com'
        end
      end

      context 'when string_key given' do
        before do
          patch "/api/v1/projects/#{project.string_key}", params: {
            project: { string_key: 'best_project' }
          }
        end

        it 'does not update string_key' do
          project.reload
          expect(project.string_key).not_to eql 'best_project'
        end
      end
    end
  end

  describe 'DELETE /api/v1/projects/:string_key' do
    let(:string_key) { 'best_project' }

    before { FactoryBot.create(:project, string_key: string_key) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/projects/#{string_key}"
      end
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'when deleting a project that exists' do
        before do
          delete "/api/v1/projects/#{string_key}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(Project.find_by(string_key: string_key)).to be nil
        end
      end

      context 'when deleting a project that does not exist' do
        before { delete '/api/v1/projects/not-valid' }

        it 'returns errors' do
          expect(response.body).to be_json_eql(%(
            { "errors": [ { "title": "Not Found" } ] }
          ))
        end

        it 'returns 404' do
          expect(response.status).to be 404
        end
      end
    end
  end
end
