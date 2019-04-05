require 'rails_helper'

RSpec.describe ExportRule, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject { FactoryBot.create(:export_rule) }

      it { is_expected.to be_a ExportRule }

      its(:dynamic_field_group)  { is_expected.to be_a DynamicFieldGroup }
      its(:field_export_profile) { is_expected.to be_a FieldExportProfile }
    end

    context 'when missing dynamic_field_group' do
      let(:export_rule) { FactoryBot.build(:export_rule, dynamic_field_group: nil) }

      it 'does not save' do
        expect(export_rule.save).to be false
      end

      it 'returns correct error' do
        export_rule.save
        expect(export_rule.errors.full_messages).to include 'Dynamic field group is required'
      end
    end

    context 'when missing field_export_profile' do
      let(:export_rule) { FactoryBot.build(:export_rule, field_export_profile: nil) }

      it 'does not save' do
        expect(export_rule.save).to be false
      end

      it 'returns correct error' do
        export_rule.save
        expect(export_rule.errors.full_messages).to include 'Field export profile is required'
      end
    end

    context 'when missing translation_logic' do
      let(:export_rule) { FactoryBot.create(:export_rule, translation_logic: nil) }

      it 'adds empty translation_logic' do
        expect(export_rule.translation_logic).to eql "[\n\n]"
      end
    end

    context 'when translation_logic is invalid' do
      let(:export_rule) { FactoryBot.build(:field_export_profile, translation_logic: 'randomstring') }

      it 'does not save' do
        expect(export_rule.save).to be false
      end

      it 'returns correct error' do
        export_rule.save
        expect(export_rule.errors.full_messages).to include 'Translation logic does not validate as JSON'
      end
    end
  end

  describe '#dynamic_field_group' do
    let(:export_rule) { FactoryBot.build(:export_rule, dynamic_field_group: nil) }
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

    before do
      export_rule.dynamic_field_group = dynamic_field_group
      export_rule.save
    end

    it 'can set dynamic_field_group' do
      expect(export_rule.dynamic_field_group).to be dynamic_field_group
    end

    it 'adds export_rule to dynamic_field_group' do
      expect(dynamic_field_group.export_rules).to match_array [export_rule]
    end
  end

  describe '#field_export_profile' do
    let(:export_rule) { FactoryBot.build(:export_rule, field_export_profile: nil) }
    let(:field_export_profile) { FactoryBot.create(:field_export_profile) }

    before do
      export_rule.field_export_profile = field_export_profile
      export_rule.save
    end

    it 'can set field_export_profile' do
      expect(export_rule.field_export_profile).to be field_export_profile
    end

    it 'adds export_rule to field_export_profile' do
      expect(field_export_profile.export_rules).to match_array [export_rule]
    end
  end
end
