require 'rails_helper'

RSpec.describe 'Publish Target requests', type: :request do
  let(:project) { FactoryBot.create(:project) }

  describe 'GET /api/v1/projects/:string_key/publish_targets' do
    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/projects/#{project.string_key}/publish_targets" }
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_user as: :read_all }

      describe 'when there are multiple results' do
        before do
          FactoryBot.create(:publish_target, project: project)
          FactoryBot.create(:publish_target, project: project, string_key: 'second_publish_target')
          get "/api/v1/projects/#{project.string_key}/publish_targets"
        end

        it 'returns all projects' do
          expect(response.body).to be_json_eql(%(
            {
              "publish_targets": [
                {
                  "api_key": "bestapikey",
                  "display_label": "Great Project Website",
                  "project": "great_project",
                  "publish_url": "https://www.example.com/publish",
                  "string_key": "great_project_website"
                },
                {
                  "api_key": "bestapikey",
                  "display_label": "Great Project Website",
                  "project": "great_project",
                  "publish_url": "https://www.example.com/publish",
                  "string_key": "second_publish_target"
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
  end

  describe 'GET /api/v1/projects/:string_key/publish_targets/:string_key' do
    let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/projects/#{project.string_key}/publish_targets/#{publish_target.string_key}"
      end
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_user as: :read_all }

      context 'when string_key is valid' do
        before do
          get "/api/v1/projects/#{project.string_key}/publish_targets/#{publish_target.string_key}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "publish_target": {
              "api_key": "bestapikey",
              "display_label": "Great Project Website",
              "project": "great_project",
              "publish_url": "https://www.example.com/publish",
              "string_key": "great_project_website"
            }
          }))
        end
      end

      context 'when string_key is invalid' do
        before { get "/api/v1/projects/#{project.string_key}/publish_targets/not_valid" }

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

  describe 'POST /api/v1/projects/:string_key/publish_targets' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post "/api/v1/projects/#{project.string_key}/publish_targets", params: { publish_target: { string_key: 'new_publish_target' } }
      end
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_user as: :administrator }

      context 'when creating a new publish target' do
        before do
          post "/api/v1/projects/#{project.string_key}/publish_targets", params: {
            publish_target: {
              display_label: 'Best Project Website',
              string_key: 'best_project_website',
              publish_url: 'https://bestproject/publish',
              api_key: 'bestprojectapikey'
            }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "publish_target": {
              "project": "#{project.string_key}",
              "display_label": "Best Project Website",
              "string_key": "best_project_website",
              "publish_url": "https://bestproject/publish",
              "api_key": "bestprojectapikey"
            }
          }))
        end
      end

      context 'when create request is missing string_key' do
        before do
          post "/api/v1/projects/#{project.string_key}/publish_targets", params: {
            publish_target: {
              display_label: 'Best Project Website',
              publish_url: 'https://bestproject/publish',
              api_key: 'bestprojectapikey'
            }
          }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returns error' do
          expect(response.body).to be_json_eql(%({
            "errors": [
              { "title": "String key can't be blank" }
            ]
          }))
        end
      end
    end
  end

  describe 'PATCH /api/v1/projects/:string_key/publish_targets/:string_key' do
    let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/projects/#{project.string_key}/publish_targets/#{publish_target.string_key}", params: { publish_target: {} }
      end
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_user as: :administrator }

      context 'when updating record' do
        before do
          patch "/api/v1/projects/#{project.string_key}/publish_targets/#{publish_target.string_key}", params: {
            publish_target: { display_label: 'Bestest Project', publish_url: 'https://best_project.com/publish' }
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          publish_target.reload
          expect(publish_target.display_label).to eql 'Bestest Project'
          expect(publish_target.publish_url).to eql 'https://best_project.com/publish'
        end
      end

      context 'when string_key given' do
        before do
          patch "/api/v1/projects/#{project.string_key}/publish_targets/#{publish_target.string_key}", params: {
            publish_target: { string_key: 'new_string_key' }
          }
        end

        it 'does not update string_key' do
          publish_target.reload
          expect(publish_target.string_key).to eql 'great_project_website'
        end
      end
    end
  end

  describe 'DELETE /api/v1/projects/:string_key/publish_targets/:string_key' do
    let(:string_key) { publish_target.string_key }
    let(:publish_target) { FactoryBot.create(:publish_target, project: project, string_key: 'great_project_publish_target') }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/projects/#{project.string_key}/publish_targets/#{string_key}"
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when deleting a publish_target that exists' do
        before do
          delete "/api/v1/projects/#{project.string_key}/publish_targets/#{string_key}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(PublishTarget.find_by(project: project, string_key: string_key)).to be nil
        end
      end

      context 'when deleting a publish_target that dooes not exist' do
        before do
          delete "/api/v1/projects/#{project.string_key}/publish_targets/not-valid"
        end

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
