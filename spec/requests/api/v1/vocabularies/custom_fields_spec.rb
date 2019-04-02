require 'rails_helper'

RSpec.describe 'Custom Fields Requests', type: :request do
  let(:connection) { instance_double('UriService::Client::Connection') }

  before do
    allow(URIService).to receive(:connection).and_return(connection)
  end

  describe 'POST /api/v1/vocabularies/:string_key/custom_fields' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/vocabularies/spells/custom_fields'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 201) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:create_custom_field).with('spells', { field_key: 'unforgiveable_spells', label: 'Unforgiveable Spells', data_type: 'boolean' }) { response }
        post '/api/v1/vocabularies/spells/custom_fields', params: {
          custom_field: { field_key: 'unforgiveable_spells', label: 'Unforgiveable Spells', data_type: 'boolean' }
        }
      end
    end
  end

  describe 'PATCH /api/v1/vocabularies/:string_key/custom_fields/:field_key' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch '/api/v1/vocabularies/spells/custom_fields/unforgiveable_spells'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:update_custom_field).with('spells', { field_key: 'unforgiveable_spells', label: 'Unforgiveable Spellssss' }) { response }
        patch '/api/v1/vocabularies/spells/custom_fields/unforgiveable_spells', params: {
          custom_field: { label: 'Unforgiveable Spellssss' }
        }
      end
    end
  end

  describe 'DELETE /api/v1/vocabularies/:string_key/custom_fields/:field_key' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete '/api/v1/vocabularies/spells/custom_fields/unforgiveable_spells'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:delete_custom_field).with('spells', 'unforgiveable_spells') { response }
        delete '/api/v1/vocabularies/spells/custom_fields/unforgiveable_spells'
      end
    end
  end
end
