# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnabledDynamicField, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject { FactoryBot.create(:enabled_dynamic_field) }

      it { is_expected.to be_a EnabledDynamicField }

      its(:digital_object_type) { is_expected.to eql 'item' }
      its(:required)            { is_expected.to be true }
      its(:locked)              { is_expected.to be false }
      its(:hidden)              { is_expected.to be false }
      its(:owner_only)          { is_expected.to be false }
      its(:default_value)       { is_expected.to be nil }

      its(:project)       { is_expected.to be_a Project }
      its(:dynamic_field) { is_expected.to be_a DynamicField }
    end

    context 'when digital_object_type missing' do
      let(:enabled_dynamic_field) { FactoryBot.build(:enabled_dynamic_field, digital_object_type: nil) }

      it 'does not save' do
        expect(enabled_dynamic_field.save).to be false
      end

      it 'returns correct error' do
        enabled_dynamic_field.save
        expect(enabled_dynamic_field.errors.full_messages).to include 'Digital object type can\'t be blank'
      end
    end

    context 'when project missing' do
      let(:enabled_dynamic_field) { FactoryBot.build(:enabled_dynamic_field, project: nil) }

      it 'does not save' do
        expect(enabled_dynamic_field.save).to be false
      end

      it 'returns correct error' do
        enabled_dynamic_field.save
        expect(enabled_dynamic_field.errors.full_messages).to include 'Project is required'
      end
    end

    context 'when dynamic_field missing' do
      let(:enabled_dynamic_field) { FactoryBot.build(:enabled_dynamic_field, dynamic_field: nil) }

      it 'does not save' do
        expect(enabled_dynamic_field.save).to be false
      end

      it 'returns correct error' do
        enabled_dynamic_field.save
        expect(enabled_dynamic_field.errors.full_messages).to include 'Dynamic field is required'
      end
    end

    context 'when dynamic_field already has an entry for the given project' do
      let(:project) { enabled_dynamic_field_1.project }
      let(:dynamic_field) { enabled_dynamic_field_1.dynamic_field }
      let(:enabled_dynamic_field_1) { FactoryBot.create(:enabled_dynamic_field) }
      let(:enabled_dynamic_field_2) { FactoryBot.build(:enabled_dynamic_field, project: project, dynamic_field: dynamic_field) }

      before { enabled_dynamic_field_2 }

      it 'does not save' do
        expect(enabled_dynamic_field_2.save).to be false
      end

      it 'returns correct error' do
        enabled_dynamic_field_2.save
        expect(enabled_dynamic_field_2.errors.full_messages).to include 'Dynamic field has already been taken'
      end
    end
  end

  describe '#destroy ' do
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
    let(:project) { FactoryBot.create(:project) }
    let(:digital_object_type) { 'item' }
    let!(:enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, dynamic_field: dynamic_field, project: project, digital_object_type: digital_object_type) }
    context 'when the enabled dynamic field is in use in the project' do
      before do
        allow(Hyacinth::Config.digital_object_search_adapter).to receive(:field_used_in_project?).and_return(true)
      end
      it 'fails to destroy, and adds an error' do
        expect(enabled_dynamic_field.destroy).to eq(false)
        expect(enabled_dynamic_field.errors.messages).to eq(
          destroy: [
            "Cannot disable #{dynamic_field.display_label} because it's used by one or more #{digital_object_type.pluralize} in #{project.display_label}"
          ]
        )
      end
    end
  end
end
