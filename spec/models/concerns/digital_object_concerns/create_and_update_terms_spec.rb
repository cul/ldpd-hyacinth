# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::CreateAndUpdateTerms, solr: true do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass, descriptive_metadata: descriptive_metadata) }
  let(:vocab) { FactoryBot.create(:vocabulary, :with_custom_field) }

  let(:field_definitions) do
    {
      dynamic_field_categories: [
        {
          display_label: 'Descriptive Metadata',
          dynamic_field_groups: [
            {
              string_key: 'mythical_creatures_subjects',
              display_label: 'Mythical Creatures Subjects',
              dynamic_fields: [
                { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: vocab.string_key }
              ]
            }
          ]
        }
      ]
    }
  end

  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions) # Define Fields
  end

  context "#create_and_update_terms" do
    context "when temporary term is provided" do
      let(:descriptive_metadata) do
        {
          'mythical_creatures_subjects' => [
            {
              'term' => {
                'pref_label' => 'Yeti',
                'harry_potter_reference' => false
              }
            }
          ]
        }
      end

      let(:rehydrated_descriptive_metadata) do
        {
          'mythical_creatures_subjects' => [
            {
              'term' => {
                'pref_label' => 'Yeti',
                'authority' => nil,
                'term_type' => Term::TEMPORARY,
                'uri' => 'temp:559aae72a74e0c9b6ccfadfe09f4da14c76808acc44ccc02ed5b5fc88d38f316',
                'alt_labels' => [],
                'harry_potter_reference' => false
              }
            }
          ]
        }
      end

      context 'and term is not present' do
        before { digital_object.send(:create_and_update_terms) }

        it 'creates new term' do
          expect(vocab.terms.find_by(pref_label: 'Yeti', term_type: Term::TEMPORARY)).not_to be nil
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end

      context 'and term is present' do
        before do
          FactoryBot.create(:temp_term, vocabulary: vocab)
          digital_object.send(:create_and_update_terms)
        end

        it 'does not create term' do
          expect(Term.count).to be 1
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end
    end

    context 'when external term is provided' do
      let(:descriptive_metadata) do
        {
          'mythical_creatures_subjects' => [
            {
              'term' => {
                'pref_label' => 'Unicorns',
                'authority' => 'fast',
                'uri' => 'http://id.worldcat.org/fast/1161301/',
                'harry_potter_reference' => true
              }
            }
          ]
        }
      end

      let(:rehydrated_descriptive_metadata) do
        {
          'mythical_creatures_subjects' => [
            {
              'term' => {
                'pref_label' => 'Unicorns',
                'authority' => 'fast',
                'term_type' => Term::EXTERNAL,
                'uri' => 'http://id.worldcat.org/fast/1161301/',
                'alt_labels' => [],
                'harry_potter_reference' => true
              }
            }
          ]
        }
      end

      context 'and term is not present' do
        before { digital_object.send(:create_and_update_terms) }

        it 'creates term' do
          expect(vocab.terms.find_by(uri: 'http://id.worldcat.org/fast/1161301/', term_type: Term::EXTERNAL)).not_to be nil
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end

      context 'without a pref_label and term is not present' do
        let(:descriptive_metadata) do
          {
            'mythical_creatures_subjects' => [
              {
                'term' => {
                  'uri' => 'http://id.worldcat.org/fast/1161301/'
                }
              }
            ]
          }
        end

        it 'raises error' do
          expect {
            digital_object.send(:create_and_update_terms)
          }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Pref label can\'t be blank'
        end
      end

      context 'and term is present' do
        before do
          FactoryBot.create(:external_term, vocabulary: vocab)
          digital_object.send(:create_and_update_terms)
        end

        it 'does not create term' do
          expect(Term.count).to be 1
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end
    end

    context 'when available term is provided with more information' do
      let(:descriptive_metadata) do
        {
          'mythical_creatures_subjects' => [
            {
              'term' => {
                'uri' => 'http://id.worldcat.org/fast/1161301/',
                'authority' => 'new_authority',
                'harry_potter_reference' => false,
                'alt_labels' => ['uni']
              }
            }
          ]
        }
      end

      context 'and data is not already present for that field' do
        let(:rehydrated_descriptive_metadata) do
          {
            'mythical_creatures_subjects' => [
              {
                'term' => {
                  'pref_label' => 'Unicorns',
                  'authority' => 'new_authority',
                  'term_type' => Term::EXTERNAL,
                  'uri' => 'http://id.worldcat.org/fast/1161301/',
                  'alt_labels' => ['uni'],
                  'harry_potter_reference' => false
                }
              }
            ]
          }
        end

        before do
          FactoryBot.create(:external_term, vocabulary: vocab, authority: nil, custom_fields: {})
          digital_object.send(:create_and_update_terms)
        end

        it 'updates term' do
          term = Term.find_by(uri: 'http://id.worldcat.org/fast/1161301/', vocabulary: vocab)
          expect(term.authority).to eql 'new_authority'
          expect(term.custom_fields).to include('harry_potter_reference' => false)
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end

      context 'and data is already present for that field' do
        let(:rehydrated_descriptive_metadata) do
          {
            'mythical_creatures_subjects' => [
              {
                'term' => {
                  'pref_label' => 'Unicorns',
                  'authority' => 'fast',
                  'term_type' => Term::EXTERNAL,
                  'uri' => 'http://id.worldcat.org/fast/1161301/',
                  'alt_labels' => ['horse with horn'],
                  'harry_potter_reference' => true
                }
              }
            ]
          }
        end

        before do
          FactoryBot.create(:external_term, vocabulary: vocab, alt_labels: ['horse with horn'])
          digital_object.send(:create_and_update_terms)
        end

        it 'does not update term' do
          term = Term.find_by(uri: 'http://id.worldcat.org/fast/1161301/', vocabulary: vocab)
          expect(term.authority).to eql 'fast'
          expect(term.custom_fields).to include('harry_potter_reference' => true)
        end

        it 'rehydrates term' do
          expect(digital_object.descriptive_metadata).to eql rehydrated_descriptive_metadata
        end
      end
    end
  end
end
