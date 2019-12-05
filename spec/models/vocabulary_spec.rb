# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vocabulary, type: :model do
  describe 'when creating a vocabulary' do
    context 'with a string key containing an invalid character' do
      let(:vocabulary) { FactoryBot.build(:vocabulary, string_key: 'mythical-creatures') }

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(
          vocabulary.errors.full_messages
        ).to include 'String key values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores'
      end
    end

    context 'with a string key that starts with a number' do
      let(:vocabulary) { FactoryBot.build(:vocabulary, string_key: '123mythical_creatures') }

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(
          vocabulary.errors.full_messages
        ).to include 'String key values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores'
      end
    end

    context 'with a string key that contains uppercase letters' do
      let(:vocabulary) { FactoryBot.build(:vocabulary, string_key: 'Mythical_Creatures') }

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(
          vocabulary.errors.full_messages
        ).to include 'String key values must start with a letter, can only have up to 240 characters and can only contain lower case letters, numbers and underscores'
      end
    end

    context 'when missing label' do
      let(:vocabulary) { FactoryBot.build(:vocabulary, label: '') }

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'Label can\'t be blank'
      end
    end

    context 'when missing string_key' do
      let(:vocabulary) { FactoryBot.build(:vocabulary, string_key: '') }

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when custom_field field_key is a reserved name' do
      let(:vocabulary) do
        FactoryBot.build(
          :vocabulary, custom_fields: { authority: { data_type: 'string', label: 'Authority' } }
        )
      end

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'Custom fields authority is a reserved field name and cannot be used'
      end
    end

    context 'when custom_field field_key starts with or contains invalid characters' do
      let(:vocabulary) do
        FactoryBot.build(
          :vocabulary, custom_fields: { AUTHORITY: { data_type: 'string', label: 'Authority' } }
        )
      end

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'Custom fields field_key can only contain lowercase alphanumeric characters and underscores and must start with a lowercase letter'
      end
    end

    context 'when custom_field missing label' do
      let(:vocabulary) do
        FactoryBot.build(
          :vocabulary, custom_fields: { classification: { data_type: 'string' } }
        )
      end

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'Custom fields each custom_field must have a label and data_type defined'
      end
    end

    context 'when custom_field missing data_type' do
      let(:vocabulary) do
        FactoryBot.build(
          :vocabulary, custom_fields: { classification: { label: 'Classification' } }
        )
      end

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include(
          'Custom fields each custom_field must have a label and data_type defined',
          'Custom fields data_type must be one of string, integer or boolean'
        )
      end
    end

    context 'when a custom_field\'s data_type is invalid' do
      let(:vocabulary) do
        FactoryBot.build(
          :vocabulary, custom_fields: { classification: { label: 'Classification', data_type: 'decimal' } }
        )
      end

      it 'returns validation error' do
        expect(vocabulary.save).to be false
        expect(vocabulary.errors.full_messages).to include 'Custom fields data_type must be one of string, integer or boolean'
      end
    end
  end

  describe '#add_custom_field' do
    let(:vocabulary) { FactoryBot.create(:vocabulary) }

    context 'when field_key is blank' do
      it 'raises an error' do
        expect { vocabulary.add_custom_field }.to raise_error 'field_key cannot be blank'
      end
    end

    context 'when field_key already exists' do
      before do
        vocabulary.add_custom_field(field_key: 'classification', label: 'classification', data_type: 'string')
        vocabulary.save
      end

      it 'raises an error' do
        expect { vocabulary.add_custom_field(field_key: 'classification') }.to raise_error 'field_key cannot be added because it\'s already a custom field'
      end
    end
  end

  describe '#update_custom_field' do
    let(:vocabulary) do
      FactoryBot.create(
        :vocabulary,
        custom_fields: { classification: { label: 'Classification', data_type: 'string' } }
      )
    end

    context 'when field_key is blank' do
      it 'raises an error' do
        expect { vocabulary.update_custom_field }.to raise_error 'field_key cannot be blank'
      end
    end

    context 'when field_key does not exist' do
      it 'raises an error' do
        expect {
          vocabulary.update_custom_field(field_key: 'special_power')
        }.to raise_error 'field_key must be present in order to update custom field'
      end
    end

    context 'when label not present' do
      before do
        vocabulary.update_custom_field(field_key: 'classification')
        vocabulary.save
        vocabulary.reload
      end

      it 'does not update label' do
        expect(vocabulary.custom_fields['classification']['label']).to eql 'Classification'
      end
    end
  end

  describe '#delete_custom_field' do
    let(:vocabulary) { FactoryBot.create(:vocabulary) }

    context 'when field_key does not exist' do
      it 'raises an error' do
        expect {
          vocabulary.delete_custom_field('classification')
        }.to raise_error 'Cannot delete a custom field that doesn\'t exist'
      end
    end
  end
end
