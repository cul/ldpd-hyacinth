require 'rails_helper'

RSpec.describe "Terms", type: :request do
  describe "POST /terms" do
    describe "when a user is not logged in" do
      it "returns a 401 (unauthorized)" do
        post terms_path(format: :json)
        expect(response.status).to be(401)
      end
    end

    context "when a user is logged in" do
      before :example do
        sign_in_admin_user
      end

      let(:term_form_data) do
        {
          term: {
            type: 'temporary',
            controlled_vocabulary_string_key: 'name',
            value: 'Some Person',
            name_type: 'personal', # custom field
          }
        }
      end

      it "successfully creates a term" do
        post(terms_path(format: :json), params: term_form_data)
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to match({
          'internal_id' => a_kind_of(Integer),
          'type' => 'temporary',
          'uri' => 'temp:306e216e2f1bf62d95ccfea1f2d836bb10cb80d3847b6847cf1d9b75913f19e5',
          'value' => 'Some Person',
          'vocabulary_string_key' => 'name',
          'name_type' => 'personal'
        })
      end

      it "ignores unpermitted parameters" do
        post(terms_path(format: :json), params: term_form_data.merge({some_unpermitted_custom_field: 'some value'}))
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to match({
          'internal_id' => a_kind_of(Integer),
          'type' => 'temporary',
          'uri' => 'temp:306e216e2f1bf62d95ccfea1f2d836bb10cb80d3847b6847cf1d9b75913f19e5',
          'value' => 'Some Person',
          'vocabulary_string_key' => 'name',
          'name_type' => 'personal'
        })
      end
    end
  end

  describe "PATCH /terms/:id" do
    let(:controlled_vocabulary) { FactoryBot.create(:controlled_vocabulary, string_key: 'name') }
    let(:term_uri) { 'https://example.com/term/lincoln_abraham' }
    let(:term_value) { 'Lincoln, Abraham' }
    let(:term_authority) { 'abc' }
    let(:term_custom_field_name_type) { 'personal' }

    let!(:term) do
      UriService.client.create_term('external', {
        vocabulary_string_key: controlled_vocabulary.string_key,
        uri: term_uri,
        value: term_value,
        additional_fields: {
          name_type: term_custom_field_name_type
        }
      })
    end

    after do
      UriService.client.delete_term(term_uri)
    end

    describe "when a user is not logged in" do
      it "returns a 401 (unauthorized)" do
        patch term_path(id: term['internal_id'], format: :json)
        expect(response.status).to be(401)
      end
    end

    context "when a user is logged in" do
      before :example do
        sign_in_admin_user
      end

      let(:term_update_form_data) do
        {
          term: {
            uri: term['uri'],
            controlled_vocabulary_string_key: term['vocabulary_string_key'],
            value: 'Lincoln Corp.',
            name_type: 'corporate', # custom field
          }
        }
      end

      it "successfully updates a term" do
        patch(term_path(id: term['internal_id'], format: :json), params: term_update_form_data)
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to eq({
          'internal_id' => term['internal_id'],
          'type' => term['type'],
          'uri' => term['uri'],
          'value' => 'Lincoln Corp.',
          'vocabulary_string_key' => term['vocabulary_string_key'],
          'name_type' => 'corporate'
        })
      end

      it "ignores unpermitted parameters" do
        patch(term_path(id: term['internal_id'], format: :json), params: term_update_form_data.merge({some_unpermitted_custom_field: 'some value'}))
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to eq({
          'internal_id' => term['internal_id'],
          'type' => term['type'],
          'uri' => term['uri'],
          'value' => 'Lincoln Corp.',
          'vocabulary_string_key' => term['vocabulary_string_key'],
          'name_type' => 'corporate'
        })
      end
    end
  end
end
