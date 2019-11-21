require 'rails_helper'

RSpec.describe 'Dynamic Field Categories Requests', type: :request do
  describe 'GET /api/v1/dynamic_field_categories' do
    before do
      FactoryBot.create(:dynamic_field_category)
      FactoryBot.create(:dynamic_field_category, display_label: 'Location')
    end

    context 'when logged in user' do
      before { sign_in_user }

      context 'when there are multiple results' do
        before do
          get '/api/v1/dynamic_field_categories'
        end

        it 'returns all dynamic_field_categories' do
          expect(response.body).to be_json_eql(%(
            {
               "dynamic_field_categories": [
                 {
                   "display_label": "Descriptive Metadata",
                   "children": [],
                   "sort_order": 3,
                   "type": "DynamicFieldCategory"
                 },
                 {
                   "display_label": "Location",
                   "children": [],
                   "sort_order": 3,
                   "type": "DynamicFieldCategory"
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

  describe 'GET /api/v1/dynamic_field_categories/:id' do
    let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

    before { sign_in_user }

    context 'when id is valid' do
      before do
        get "/api/v1/dynamic_field_categories/#{dynamic_field_category.id}"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          {
            "dynamic_field_category": {
              "display_label": "Descriptive Metadata",
              "children": [

              ],
              "sort_order": 3,
              "type": "DynamicFieldCategory"
            }
          }
        ))
      end
    end

    context 'when id is invalid' do
      before do
        get '/api/v1/dynamic_field_categories/1234'
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

  describe 'POST /api/v1/dynamic_field_categories' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/dynamic_field_categories', params: { dynamic_field_category: { display_label: 'Location' } }
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when creating a new dynamic field category' do
        before do
          post '/api/v1/dynamic_field_categories', params: { dynamic_field_category: { display_label: 'Location', sort_order: '8' } }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "dynamic_field_category": {
                "display_label": "Location",
                "children": [],
                "sort_order": 8,
                "type": "DynamicFieldCategory"
              }
            }
          ))
        end
      end

      context 'when creating without a display_label' do
        before do
          post '/api/v1/dynamic_field_categories', params: { dynamic_field_category: { sort_order: '8' } }
        end

        it 'returns 400' do
          expect(response.status).to be 400
        end

        it 'returns errors' do
          expect(response.body).to be_json_eql(%(
            {
              "errors": [
                { "title": "Display label can't be blank" }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'PATCH /api/v1/dynamic_field_categories/:id' do
    let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/dynamic_field_categories/#{dynamic_field_category.id}", params: { dynamic_field_category: {} }
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when updating display_label' do
        before do
          patch "/api/v1/dynamic_field_categories/#{dynamic_field_category.id}", params: { dynamic_field_category: { display_label: 'New Location' } }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          dynamic_field_category.reload
          expect(dynamic_field_category.display_label).to eql 'New Location'
        end
      end
    end
  end

  describe 'DELETE /api/v1/dynamic_field_categories/:id' do
    let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/dynamic_field_categories/#{dynamic_field_category.id}"
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when deleting a dynamic_field_category that exists' do
        let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }
        let(:id) { dynamic_field_category.id }

        before do
          delete "/api/v1/dynamic_field_categories/#{id}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(DynamicFieldCategory.find_by(id: id)).to be nil
        end
      end

      context 'when deleting a dynamic_field_category that does not exist' do
        before { delete '/api/v1/dynamic_field_categories/123' }

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
