require 'rails_helper'

RSpec.describe TermsController, type: :controller do
  before { sign_in_admin_user_controller_spec() }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TermsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe '#create' do
    let(:controlled_vocabulary_string_key) { "terms_controller_vocab" }
    let(:controlled_vocabulary) { FactoryBot.create(:controlled_vocabulary, string_key: controlled_vocabulary_string_key) }

    let(:create_params) {
      {
        term: {
          'controlled_vocabulary_string_key' => controlled_vocabulary.string_key,
          'value' => term_value,
          'type' => term_type,
          'authority' => term_authority
        }
      }
    }

    context 'simple success case' do
      let(:term_value) { 'Term Value' }
      let(:term_type) { 'temporary' }
      let(:term_authority) { 'test' }

      let(:expected_id) { 42 }
      let(:created_term) { { 'internal_id' => expected_id } }

      let(:response_json) { JSON.load(response.body) }
      before do
        allow(UriService.client).to receive(:create_term).with(term_type, hash_including(value: term_value)).and_return(created_term)
      end
      it 'works in the simplest case' do
        post :create, params: create_params, session: valid_session, format: 'json'
        expect(response_json).to include('internal_id' => expected_id)
      end
    end
  end
end
