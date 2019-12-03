# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Terms Requests', type: :request do
  let(:connection) { instance_double 'UriService::Client::Connection' }

  before do
    allow(URIService).to receive(:connection).and_return(connection)
  end

  describe 'GET /api/v1/vocabularies/:string_key/terms' do
    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 200) }

      before { sign_in_user }

      it 'makes correct request to external service' do
        expect(connection).to receive(:search_terms).with('spells', {}) { response }
        get '/api/v1/vocabularies/spells/terms'
      end

      it 'makes correct request to external service with parameters' do
        expect(connection).to receive(:search_terms).with('spells', { authority: 'potter' }) { response }
        get '/api/v1/vocabularies/spells/terms', params: { authority: 'potter' }
      end
    end
  end

  describe 'GET /api/v1/vocabularies/:string_key/terms/:uri' do
    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 200) }

      before { sign_in_user }

      it 'makes correct request to external service' do
        expect(connection).to receive(:term).with('spells', 'https://pottermore.com/spells/alohomora') { response }
        get '/api/v1/vocabularies/spells/terms/https%3A%2F%2Fpottermore.com%2Fspells%2Falohomora'
      end
    end
  end

  describe 'POST /api/v1/vocabularies/:string_key/terms' do
    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 201) }

      before { sign_in_user }

      it 'makes correct request to external service' do
        expect(connection).to receive(:create_term).with('spells', {
          uri: 'https://pottermore.com/spells/alohomora', pref_label: 'Alohomora', authority: 'potter'
        }) { response }
        post '/api/v1/vocabularies/spells/terms', params: {
          term: { uri: 'https://pottermore.com/spells/alohomora', pref_label: 'Alohomora', authority: 'potter' }
        }
      end
    end
  end

  describe 'PATCH /api/v1/vocabularies/:string_key/terms/:uri' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch '/api/v1/vocabularies/spells/terms/https%3A%2F%2Fpottermore.com%2Fspells%2Falohomora'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 200) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:update_term).with('spells', {
          pref_label: 'ALOHOMORA', uri: 'https://pottermore.com/spells/alohomora'
        }) { response }
        patch '/api/v1/vocabularies/spells/terms/https%3A%2F%2Fpottermore.com%2Fspells%2Falohomora',
              params: { term: { pref_label: 'ALOHOMORA' } }
      end
    end
  end

  describe 'DELETE /api/v1/vocabularies/:string_key/terms/:uri' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete '/api/v1/vocabularies/spells/terms/https%3A%2F%2Fpottermore.com%2Fspells%2Falohomora'
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:response) { instance_double('UriService::Client::Response', data: {}, status: 204) }

      before { sign_in_user as: :vocabulary_manager }

      it 'makes correct request to external service' do
        expect(connection).to receive(:delete_term).with('spells', 'https://pottermore.com/spells/alohomora') { response }
        delete '/api/v1/vocabularies/spells/terms/https%3A%2F%2Fpottermore.com%2Fspells%2Falohomora'
      end
    end
  end
end
