require 'rails_helper'

RSpec.describe 'Field Export Profiles Requests', type: :request do
  describe 'GET /api/v1/field_export_profiles' do
    before do
      FactoryBot.create(:field_export_profile)
      FactoryBot.create(:field_export_profile, name: 'rightsMetadata')
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) { get '/api/v1/field_export_profiles' }
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when there are multiple results' do
        before { get '/api/v1/field_export_profiles' }

        it 'returns all field export profiles' do
          expect(response.body).to be_json_eql(%(
            {
              "field_export_profiles": [
                {
                  "name": "descMetadata"
                },
                {
                  "name": "rightsMetadata"
                }
              ]
            }
          )).excluding(:translation_logic)
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end
      end
    end
  end

  describe 'GET /api/v1/field_export_profiles/:id' do
    let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/field_export_profiles/#{field_export_profile.id}" }
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when id is valid' do
        before do
          get "/api/v1/field_export_profiles/#{field_export_profile.id}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%({
            "field_export_profile": {
              "name": "descMetadata"
            }
          })).excluding(:translation_logic)
        end
      end

      context 'when id is invalid' do
        before { get '/api/v1/field_export_profiles/1234' }

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

  describe 'POST /api/v1/field_export_profiles' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/field_export_profiles', params: { field_export_profile: { name: 'descMetadata' } }
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when creating a new field_export_profile' do
        before do
          post '/api/v1/field_export_profiles', params: {
            field_export_profile: { name: 'descMetadata', translation_logic: '{}' }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "field_export_profile": {
                "name": "descMetadata",
                "translation_logic": "{\\n}"
              }
            }
          ))
        end
      end

      context 'when create is missing name' do
        before do
          post '/api/v1/field_export_profiles', params: {
            field_export_profile: { translation_logic: '{}' }
          }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returns error' do
          expect(response.body).to be_json_eql(%({
            "errors": [
              { "title": "Name can't be blank" }
            ]
          }))
        end
      end
    end
  end

  describe 'PATCH /api/v1/field_export_profiles/:id' do
    let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/field_export_profiles/#{field_export_profile.id}", params: { field_export_profile: {} }
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when updating name' do
        before do
          patch "/api/v1/field_export_profiles/#{field_export_profile.id}", params: { field_export_profile: { name: 'DescMetadata' } }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          field_export_profile.reload
          expect(field_export_profile.name).to eql 'DescMetadata'
        end
      end
    end
  end

  describe 'DELETE /api/v1/field_export_profiles/:id' do
    let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/field_export_profiles/#{field_export_profile.id}"
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when deleting a field_export_profile that exists' do
        let(:id) { field_export_profile.id }

        before do
          delete "/api/v1/field_export_profiles/#{id}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(FieldExportProfile.find_by(id: id)).to be nil
        end
      end
    end

    context 'when deleting a field_export_profile that does not exist' do
      before { delete '/api/v1/field_export_profiles/123' }

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
