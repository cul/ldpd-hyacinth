require 'rails_helper'

RSpec.describe 'Vocabularies Request', type: :request do
  let(:connection) { double('connection') }

  before do
    allow(URIService).to receive(:connection).and_return(connection)
  end

  describe 'GET /api/v1/vocabularies' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get '/api/v1/vocabularies'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { double(data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:vocabularies).with({}) { response }
        get '/api/v1/vocabularies'
      end

      it 'makes correct request to external service with parameters' do
        expect(connection).to receive(:vocabularies).with(page: 2) { response }
        get '/api/v1/vocabularies', params: { page: 2 }
      end
    end
  end

  describe 'GET /api/v1/vocabularies/:string_key' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get '/api/v1/vocabularies/spells'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { double(data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:vocabulary).with('spells') { response }
        get '/api/v1/vocabularies/spells'
      end
    end
  end

  describe 'POST /api/v1/vocabularies' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/vocabularies'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { double(data: {}, status: 201) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:create_vocabulary).with({ string_key: 'spells', label: 'Spells' }) { response }
        post '/api/v1/vocabularies/', params: {
          vocabulary: { string_key: 'spells', label: 'Spells' }
        }
      end
    end
  end

  describe 'PATCH /api/v1/vocabularies/:string_key' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch '/api/v1/vocabularies/spells'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { double(data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:update_vocabulary).with({ string_key: 'spells', label: 'New Spells' }) { response }
        patch '/api/v1/vocabularies/spells', params: { vocabulary: { label: 'New Spells' } }
      end
    end
  end

  describe 'DELETE /api/v1/vocabularies/:string_key' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete '/api/v1/vocabularies/spells'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { double(data: {}, status: 204) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:delete_vocabulary).with('spells') { response }
        delete '/api/v1/vocabularies/spells'
      end
    end
  end
end
