require 'rails_helper'

RSpec.describe 'Field Sets Requests', type: :request do
  let(:project) { FactoryBot.create(:project) }

  describe 'GET /api/v1/projects/:string_key/field_sets' do
    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/projects/#{project.string_key}/field_sets" }
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_project_contributor to: :read_objects, project: project }

      describe 'when there are multiple results' do
        before do
          FactoryBot.create(:field_set, project: project)
          FactoryBot.create(:field_set, display_label: 'Serial Part', project: project)
          get "/api/v1/projects/#{project.string_key}/field_sets"
        end

        it 'returns all field sets' do
          expect(response.body).to be_json_eql(%(
            {
              "field_sets": [
                { "display_label": "Monographs" },
                { "display_label": "Serial Part" }
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

  describe 'GET /api/v1/projects/:string_key/field_sets/:id' do
    let(:field_set) { FactoryBot.create(:field_set, project: project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/projects/#{project.string_key}/field_sets/#{field_set.id}"
      end
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_project_contributor to: :read_objects, project: project }

      context 'when id is valid' do
        before do
          get "/api/v1/projects/#{project.string_key}/field_sets/#{field_set.id}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "field_set": { "display_label": "Monographs" }
          }))
        end
      end

      context 'when id is invalid' do
        before { get "/api/v1/projects/#{project.string_key}/field_sets/1234" }

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

  describe 'POST /api/v1/projects/:string_key/field_sets' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post "/api/v1/projects/#{project.string_key}/field_sets", params: { field_set: { display_label: 'Monograph Part' } }
      end
    end

    context 'when logged in user is project manager' do
      before { sign_in_project_contributor to: :manage, project: project }

      context 'when creating a new field sets' do
        before do
          post "/api/v1/projects/#{project.string_key}/field_sets", params: {
            field_set: { display_label: 'Monograph Part' }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "field_set": { "display_label": "Monograph Part" }
          }))
        end
      end

      context 'when create request is missing display_label' do
        before do
          post "/api/v1/projects/#{project.string_key}/field_sets", params: {
            field_set: { label: 'wrong parameter' }
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

  describe 'PATCH /api/v1/projects/:string_key/field_sets/:id' do
    let(:field_set) { FactoryBot.create(:field_set, project: project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/projects/#{project.string_key}/field_sets/#{field_set.id}", params: { field_set: {} }
      end
    end

    context 'when logged in user is project manager' do
      before { sign_in_project_contributor to: :manage, project: project }

      context 'when updating record' do
        before do
          patch "/api/v1/projects/#{project.string_key}/field_sets/#{field_set.id}",
                params: { field_set: { display_label: 'Monograph Part' } }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          field_set.reload
          expect(field_set.display_label).to eql 'Monograph Part'
        end
      end

      context 'when updating record with invalid display_label' do
        before do
          patch "/api/v1/projects/#{project.string_key}/field_sets/#{field_set.id}",
                params: { field_set: { display_label: nil } }
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

  describe 'DELETE /api/v1/projects/:string_key/field_sets/:id' do
    let(:field_set) { FactoryBot.create(:field_set, project: project) }
    let(:id)        { field_set.id }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/projects/#{project.string_key}/field_sets/#{id}"
      end
    end

    context 'when logged in user is project manager' do
      before { sign_in_project_contributor to: :manage, project: project }

      context 'when deleting a field set that exists' do
        before do
          delete "/api/v1/projects/#{project.string_key}/field_sets/#{id}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(PublishTarget.find_by(id: id)).to be nil
        end
      end

      context 'when deleting a field set that doesn\'t exist' do
        before do
          delete "/api/v1/projects/#{project.string_key}/field_sets/12345"
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
