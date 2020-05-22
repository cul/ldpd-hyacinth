# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Term, type: :model, solr: true do
  let(:term_solr_doc) { Hyacinth::Config.term_search_adapter.find(term.vocabulary.string_key, term.uri) }

  describe 'when creating a external term' do
    let(:term) { FactoryBot.create(:external_term) }
    let(:expected_solr_doc) do
      {
        'uri' => 'http://id.worldcat.org/fast/1161301/',
        'pref_label' => 'Unicorns',
        'term_type' => 'external',
        'authority' => 'fast',
        'custom_fields' => '{"harry_potter_reference":true}'
      }
    end

    it 'sets uri_hash' do
      expect(term.uri_hash).to eql '37e37aa82a659464081b368efa3f06dc12e56bd07ed8237f4c4a05f401015e52'
    end

    it 'sets uid' do
      expect(term.uid).not_to be blank?
    end

    it 'creates solr document' do
      expect(term_solr_doc).to include(expected_solr_doc)
    end

    context 'with an invalid URI', solr: false do
      let(:term) { FactoryBot.build(:external_term, uri: 'ldfkja') }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Uri is invalid'
      end
    end

    context 'with a missing uri', solr: false do
      let(:term) { FactoryBot.build(:external_term, uri: '') }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.keys).to include :uri
        expect(term.errors.keys).not_to include :uri_hash
        expect(term.errors.full_messages).to include 'Uri can\'t be blank'
      end
    end

    context 'when uri is already represented in vocabulary' do
      let(:term_0) { FactoryBot.create(:external_term) }
      let(:term)   { FactoryBot.build(:external_term, vocabulary: term_0.vocabulary) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Uri hash unique check failed. This uri already exists in this vocabulary.'
      end
    end

    context 'when uri is already represented in a different vocabulary' do
      let(:term_0) { FactoryBot.create(:external_term) }
      let(:new_vocabulary) { FactoryBot.create(:vocabulary, string_key: 'fantastic_beasts') }
      let(:term) { FactoryBot.build(:external_term, custom_fields: {}, vocabulary: new_vocabulary) }

      it 'saves successfully' do
        expect(term.save).to be true
      end
    end
  end

  describe 'when creating a local term' do
    let(:term) { FactoryBot.create(:local_term) }

    it 'sets local term uri' do
      expect(term.uri).to start_with "#{Term.local_uri_prefix}term"
    end

    it 'sets uri_hash' do
      expect(term.uri_hash).not_to be blank?
    end

    it 'sets uid' do
      expect(term.uid).not_to be blank?
    end

    context 'when missing local_uri_prefix in config/uri_service.yml' do
      before do
        stub_const('HYACINTH', {})
      end

      it 'raises error' do
        expect { term }.to raise_error 'Missing local_uri_prefix in config/hyacinth.yml'
      end
    end

    it 'creates solr document' do
      expect(term_solr_doc).to include(
        'pref_label' => 'Dragons',
        'term_type' => 'local',
        'custom_fields' => '{"harry_potter_reference":true}'
      )
    end
  end

  describe 'when creating temporary term' do
    let(:term) { FactoryBot.create(:temp_term) }

    it 'sets temporary term uri' do
      expect(term.uri).to start_with 'temp:'
    end

    it 'sets uri_hash' do
      expect(term.uri_hash).not_to be blank?
    end

    it 'sets uid' do
      expect(term.uid).not_to be blank?
    end

    context 'when alt_labels is set' do
      let(:term) { FactoryBot.build(:temp_term, alt_labels: ['Big Foot']) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Alt labels is not allowed for temporary terms'
      end
    end

    context 'when there is a temporary term for the label given' do
      let(:term_0) { FactoryBot.create(:temp_term) }
      let(:term) { FactoryBot.build(:temp_term, vocabulary: term_0.vocabulary) }

      it 'returns validation errors' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Uri hash unique check failed. This uri already exists in this vocabulary.'
      end
    end

    it 'creates solr document' do
      expect(term_solr_doc).to include(
        'pref_label' => 'Yeti',
        'term_type' => 'temporary',
        'custom_fields' => '{"harry_potter_reference":false}'
      )
    end
  end

  describe 'when creating a term' do
    context 'with missing pref_label' do
      let(:term) { FactoryBot.build(:external_term, pref_label: nil) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Pref label can\'t be blank'
      end
    end

    context 'with missing term_type' do
      let(:term) { FactoryBot.build(:external_term, term_type: nil) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include('Term type can\'t be blank')
      end
    end

    context 'with invalid term_type' do
      let(:term) { FactoryBot.build(:external_term, term_type: 'not_valid') }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include('Term type is not valid: not_valid')
      end
    end

    context 'with invalid custom_field' do
      let(:term) { FactoryBot.build(:external_term, custom_fields: { 'fake_custom_field' => 'blahblahblah' }) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Custom field fake_custom_field is not a valid custom field.'
      end
    end

    context 'with invalid uid' do
      let(:term) { FactoryBot.build(:external_term, uid: 'not-valid-at-all') }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Uid is invalid'
      end
    end

    context 'with a boolean in a string custom_field' do
      let(:vocab) do
        FactoryBot.create(:vocabulary, custom_fields: { harry_potter_reference: { data_type: 'string', label: 'Harry Potter Reference' } })
      end
      let(:term) { FactoryBot.build(:external_term, vocabulary: vocab) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Custom field harry_potter_reference must be a valid string'
      end

      context 'when not validated' do
        it 'raises error' do
          expect {
            term.save(validate: false)
          }.to raise_error 'custom_field harry_potter_reference must be a valid string. Could not cast "true" to a valid string'
        end
      end
    end

    context 'with a string in an integer custom_field' do
      let(:vocab) do
        FactoryBot.create(:vocabulary, custom_fields: { harry_potter_reference: { data_type: 'integer', label: 'Harry Potter Reference' } })
      end
      let(:term) { FactoryBot.build(:external_term, vocabulary: vocab, custom_fields: { harry_potter_reference: 'yes' }) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Custom field harry_potter_reference must be a valid integer'
      end

      context 'when not validated' do
        it 'raises error' do
          expect {
            term.save(validate: false)
          }.to raise_error 'custom_field harry_potter_reference must be a valid integer. Could not cast "yes" to a valid integer'
        end
      end
    end

    context 'with a string (that\'s an integer) in an integer custom_field' do
      let(:vocab) do
        FactoryBot.create(:vocabulary, custom_fields: { harry_potter_reference: { data_type: 'integer', label: 'Harry Potter Reference' } })
      end
      let(:term) { FactoryBot.build(:external_term, vocabulary: vocab, custom_fields: { harry_potter_reference: '1234' }) }

      it 'successfully saves' do
        expect(term.save).to be true
      end

      it 'correctly casts value to integer' do
        term.save
        expect(term.custom_fields[:harry_potter_reference]).to be_a Integer
      end
    end

    context 'with a string (that\'s a boolean) in a boolean custom_field' do
      let(:vocab) do
        FactoryBot.create(:vocabulary, custom_fields: { harry_potter_reference: { data_type: 'boolean', label: 'Harry Potter Reference' } })
      end
      let(:term) { FactoryBot.build(:external_term, vocabulary: vocab, custom_fields: { harry_potter_reference: 'true' }) }

      it 'successfully saves' do
        expect(term.save).to be true
      end

      it 'correctly casts value to boolean' do
        term.save
        expect(term.custom_fields[:harry_potter_reference]).to be_a TrueClass
      end
    end

    context 'with a integer in a boolean custom_field' do
      let(:term) { FactoryBot.build(:external_term, custom_fields: { harry_potter_reference: 134 }) }

      it 'returns validation error' do
        expect(term.save).to be false
        expect(term.errors.full_messages).to include 'Custom field harry_potter_reference must be a valid boolean'
      end

      context 'when not validated' do
        it 'raises error' do
          expect {
            term.save(validate: false)
          }.to raise_error 'custom_field harry_potter_reference must be a valid boolean. Could not cast "134" to a valid boolean'
        end
      end
    end

    context 'with a integer custom_field' do
      let(:vocab) do
        FactoryBot.create(:vocabulary, custom_fields: { harry_potter_reference: { data_type: 'integer', label: 'Harry Potter Reference' } })
      end
      let(:term) { FactoryBot.build(:external_term, vocabulary: vocab, custom_fields: { harry_potter_reference: 4 }) }

      it 'saves successfully' do
        expect(term.save).to be true
      end
    end

    context 'when vocabulary is locked' do
      let(:vocab) { FactoryBot.create(:vocabulary) }

      before { vocab.update(locked: true) }

      it 'raises error' do
        expect {
          Term.create(vocabulary: vocab, pref_label: 'new_term', term_type: Term::TEMPORARY)
        }.to raise_error(Hyacinth::Exceptions::VocabularyLocked)
      end
    end
  end

  describe 'when updating record' do
    let(:term) { FactoryBot.create(:external_term) }

    it 'cannot change uid' do
      expect(term.update(uid: 1234)).to be false
    end

    it 'cannot change term_type' do
      expect(term.update(term_type: 'local')).to be false
    end

    it 'cannot change uri' do
      expect(term.update(uri: 'https://example.com/term/fakes')).to be false
    end

    it 'updates solr document' do
      term.update(alt_labels: ['new_label'])
      expect(term_solr_doc).to include('alt_labels' => ['new_label'])
    end

    context 'of a temporary term' do
      let(:term) { FactoryBot.create(:temp_term) }

      it 'cannot change pref_label' do
        expect(term.update(pref_label: 'Big Foot')).to be false
      end
    end

    context 'when vocabulary is locked' do
      before { term.vocabulary.update(locked: true) }

      it 'raises error' do
        expect { term.update(authority: "new") }.to raise_error(Hyacinth::Exceptions::VocabularyLocked)
      end
    end
  end

  describe 'when destroying a term' do
    let(:term) { FactoryBot.create(:external_term) }

    it 'deletes solr document' do
      expect(term_solr_doc).not_to be nil
      term.destroy
      expect(Hyacinth::Config.term_search_adapter.find(term.vocabulary.string_key, term.uri)).to be nil
    end

    context 'when vocabulary is locked' do
      before { term.vocabulary.update(locked: true) }

      it 'raises error' do
        expect { term.destroy }.to raise_error(Hyacinth::Exceptions::VocabularyLocked)
      end
    end
  end
end
