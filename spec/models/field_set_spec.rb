# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldSet, type: :model do
  describe '#new' do
    context 'when creating with correct parameters' do
      subject(:field_set) { FactoryBot.create(:field_set) }

      it { is_expected.to be_a FieldSet }

      its(:display_label) { is_expected.to eql 'Monographs' }
      its(:project)       { is_expected.to be_a Project }
    end

    context 'when creating without display_label' do
      let(:fieldset) { FactoryBot.build(:field_set, display_label: nil) }

      it 'does not save' do
        expect(fieldset.save).to be false
      end

      it 'returns correct error' do
        fieldset.save
        expect(fieldset.errors.full_messages).to include 'Display label can\'t be blank'
      end
    end
  end

  describe '#enabled_dynamic_fields' do
    let(:field_set) { FactoryBot.create(:field_set) }
    let(:enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, project: field_set.project) }
    let(:new_dynamic_field) do
      FactoryBot.create(
        :dynamic_field,
        string_key: 'name', dynamic_field_group: enabled_dynamic_field.dynamic_field.dynamic_field_group
      )
    end

    let(:enabled_dynamic_field_2) do
      FactoryBot.create(:enabled_dynamic_field, project: field_set.project, dynamic_field: new_dynamic_field)
    end

    before do
      enabled_dynamic_field
      field_set.enabled_dynamic_fields << enabled_dynamic_field
    end

    it 'adds enabled_dynamic_field to field_set' do
      field_set.reload
      expect(field_set.enabled_dynamic_fields).to include enabled_dynamic_field
    end

    it 'adds field_set to enabled_dynamic_field' do
      enabled_dynamic_field.reload
      expect(enabled_dynamic_field.field_sets).to include field_set
    end

    it 'can add multiple enabled_dynamic_fields' do
      field_set.enabled_dynamic_fields << enabled_dynamic_field_2
      field_set.reload
      expect(field_set.enabled_dynamic_fields).to match_array [enabled_dynamic_field, enabled_dynamic_field_2]
    end
  end
end
