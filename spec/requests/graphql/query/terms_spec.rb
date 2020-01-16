# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query for Terms', type: :request, solr: true do
  let(:vocab) { FactoryBot.create(:vocabulary, :with_custom_field) }

  let(:external_term) do
    %(
      {
        "prefLabel": "Unicorns",
        "uri": "http://id.worldcat.org/fast/1161301/",
        "altLabels": ["Uni"],
        "authority": "fast",
        "termType": "external",
        "customFields": [
          { "field": "harry_potter_reference", "value": true }
        ]
      }
    )
  end

  let(:local_term) do
    %(
      {
        "prefLabel": "Dragons",
        "altLabels": [],
        "authority": null,
        "termType": "local",
        "customFields": [
          { "field": "harry_potter_reference", "value": true }
        ]
      }
    )
  end

  let(:temporary_term) do
    %(
      {
        "altLabels": [],
        "prefLabel": "Yeti",
        "authority": null,
        "termType": "temporary",
        "uri": "temp:559aae72a74e0c9b6ccfadfe09f4da14c76808acc44ccc02ed5b5fc88d38f316",
        "customFields": [
          { "field": "harry_potter_reference", "value": false }
        ]
      }
    )
  end

  shared_examples 'json contains external term' do
    it 'contains external term' do
      expect(response.body).to include_json(external_term).at_path('data/vocabulary/terms/nodes')
    end
  end

  shared_examples 'json contains local term' do
    it 'contains local term' do
      expect(response.body).to include_json(local_term).at_path('data/vocabulary/terms/nodes').excluding(:uri)
    end
  end

  shared_examples 'json contains temporary term' do
    it 'contains temp term' do
      expect(response.body).to include_json(temporary_term).at_path('data/vocabulary/terms/nodes')
    end
  end

  shared_examples 'json includes exact number of terms' do |total_results|
    it "contains #{total_results} results" do
      expect(response.body).to have_json_size(total_results).at_path('data/vocabulary/terms/nodes')
    end
  end

  before do
    FactoryBot.create(:external_term, alt_labels: ['Uni'], vocabulary: vocab)
    FactoryBot.create(:local_term, vocabulary: vocab)
    FactoryBot.create(:temp_term, vocabulary: vocab)
  end

  context 'when user logged in' do
    before { sign_in_user }

    context 'when terms are part of a closed vocabulary' do
      include_context 'json includes exact number of terms', 3

      before do
        vocab.update(locked: true)
        graphql query
      end
    end

    context 'with no filters' do
      include_context 'json contains temporary term'
      include_context 'json contains local term'
      include_context 'json contains external term'
      include_context 'json includes exact number of terms', 3

      before { graphql query }
    end

    context 'by query' do
      include_context 'json contains local term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(query: 'dragon')
      end
    end

    context 'by exact authority string' do
      include_context 'json contains external term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(filters: [{ field: 'authority', value: 'fast' }])
      end
    end

    context 'by exact uri string' do
      include_context 'json contains external term'
      include_context 'json includes exact number of terms', 1
      # include_context 'json includes pagination', 0, 20, 1

      before do
        graphql query(filters: [{ field: 'uri', value: 'http://id.worldcat.org/fast/1161301/' }])
      end
    end

    context 'by exact pref_label' do
      include_context 'json contains temporary term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(filters: [{ field: 'pref_label', value: 'Yeti' }])
      end
    end

    context 'by exact alt_labels' do
      include_context 'json contains external term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(filters: [{ field: 'alt_labels', value: 'Uni' }])
      end
    end

    context `by exact term_type` do
      include_context 'json contains temporary term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(filters: [{ field: 'term_type', value: 'temporary' }])
      end
    end

    context 'by custom field' do
      include_context 'json contains external term'
      include_context 'json contains local term'
      include_context 'json includes exact number of terms', 2

      before do
        graphql query(filters: [{ field: 'harry_potter_reference', value: true }])
      end
    end

    context 'by invalid custom field' do
      before do
        graphql query(filters: [{ field: "dangerous", value: true }])
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(
          %("dangerous is an invalid filter")
        ).at_path('errors/0/message')
      end
    end

    context 'with camelCased field' do
      include_context 'json contains external term'
      include_context 'json includes exact number of terms', 1

      before do
        graphql query(filters: [{ field: 'prefLabel', value: 'Unicorns' }])
      end
    end
  end

  def query(query: nil, filters: [])
    filters = filters.map { |f| "{ field: \"#{f[:field]}\", value: \"#{f[:value]}\"}" }
                     .join(', ')
                     .prepend('[')
                     .concat(']')

    <<~GQL
      query {
        vocabulary(stringKey: "#{vocab.string_key}") {
          terms(limit: 5, query: "#{query}", filters: #{filters}) {
            nodes {
              prefLabel
              uri
              altLabels
              authority
              termType
              customFields {
                field
                value
              }
            }
          }
        }
      }
    GQL
  end
end
