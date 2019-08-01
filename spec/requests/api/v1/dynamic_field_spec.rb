require 'rails_helper'

RSpec.describe 'Dynamic Fields Requests', type: :request do
  describe 'GET /api/v1/dynamic_fields/:id' do
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/dynamic_fields/#{dynamic_field.id}" }
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when id is valid' do
        before do
          get "/api/v1/dynamic_fields/#{dynamic_field.id}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "dynamic_field": {
                "controlled_vocabulary": "name_role",
                "display_label": "Value",
                "field_type": "controlled_term",
                "filter_label": "Name",
                "is_facetable": true,
                "is_identifier_searchable": false,
                "is_keyword_searchable": false,
                "is_title_searchable": false,
                "select_options": null,
                "sort_order": 7,
                "string_key": "term",
                "type": "DynamicField"
              }
            }
          ))
        end
      end

      context 'when id is invalid' do
        before do
          get '/api/v1/dynamic_fields/1234'
        end

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

  describe 'POST /api/v1/dynamic_fields' do
    let(:parent) { FactoryBot.create(:dynamic_field_group) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/dynamic_fields', params: { dynamic_field: { string_key: 'new_term' } }
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when creating a new dynamic field' do
        before do
          post '/api/v1/dynamic_fields', params: {
            dynamic_field: {
              string_key: 'term', display_label: 'Term', field_type: 'controlled_term', controlled_vocabulary: 'names',
              sort_order: 6, dynamic_field_group_id: parent.id, is_facetable: true
            }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "dynamic_field": {
                "controlled_vocabulary": "names",
                "display_label": "Term",
                "field_type": "controlled_term",
                "filter_label": null,
                "is_facetable": true,
                "is_identifier_searchable": false,
                "is_keyword_searchable": false,
                "is_title_searchable": false,
                "select_options": null,
                "sort_order": 6,
                "string_key": "term",
                "type": "DynamicField"
              }
            }
          ))
        end
      end

      context 'when creating without a display_label' do
        before do
          post '/api/v1/dynamic_fields', params: {
            dynamic_field: {
              display_label: 'Term', field_type: 'controlled_term', controlled_vocabulary: 'names',
              sort_order: 6, dynamic_field_group_id: parent.id, is_facetable: true
            }
          }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returns errors' do
          expect(response.body).to be_json_eql(%(
            {
              "errors": [
                { "title": "String key can't be blank" }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'PATCH /api/v1/dynamic_fields/:id' do
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/dynamic_fields/#{dynamic_field.id}", params: { dynamic_field: {} }
      end
    end

    context 'when logged in user is an administator' do
      before { sign_in_user as: :administrator }

      context 'when updating display_label' do
        before do
          patch "/api/v1/dynamic_fields/#{dynamic_field.id}", params: { dynamic_field: { display_label: 'New Location' } }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          dynamic_field.reload
          expect(dynamic_field.display_label).to eql 'New Location'
        end
      end

      context 'when updating to incorrect field type' do
        before do
          patch "/api/v1/dynamic_fields/#{dynamic_field.id}", params: { dynamic_field: { field_type: 'not-valid' } }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returms errors' do
          expect(response.body).to be_json_eql(%(
            {
              "errors": [
                { "title": "Field type is not among the list of allowed values" }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'DELETE /api/v1/dynamic_fields/:id' do
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/dynamic_fields/#{dynamic_field.id}"
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when deleting a dynamic_field that exists' do
        let(:id) { dynamic_field.id }

        before do
          delete "/api/v1/dynamic_fields/#{id}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(DynamicField.find_by(id: id)).to be nil
        end
      end

      context 'when deleting a dynamic_field that does not exist' do
        before { delete '/api/v1/dynamic_fields/123' }

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
