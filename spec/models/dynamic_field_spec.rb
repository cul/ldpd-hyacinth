# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamicField, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject { FactoryBot.create(:dynamic_field) }

      it { is_expected.to be_a DynamicField }

      its(:string_key) { is_expected.to eql 'term' }
      its(:path) { is_expected.to eql 'name/term' }
      its(:display_label) { is_expected.to eql 'Value' }
      its(:field_type) { is_expected.to eql DynamicField::Type::CONTROLLED_TERM }
      its(:sort_order) { is_expected.to be 7 }
      its(:filter_label) { is_expected.to eql 'Name' }
      its(:is_facetable) { is_expected.to be true }
      its(:controlled_vocabulary) { is_expected.to eql 'name_role' }
      its(:select_options) { is_expected.to be_nil }
      its(:is_keyword_searchable) { is_expected.to be false }
      its(:is_title_searchable) { is_expected.to be false }
      its(:is_identifier_searchable) { is_expected.to be false }
      its(:dynamic_field_group) { is_expected.to be_a DynamicFieldGroup }
    end

    context 'when missing string_key' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, string_key: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when missing field_type' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Field type can\'t be blank'
      end
    end

    context 'when field_type invalid' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: 'not-valid') }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Field type is not among the list of allowed values'
      end
    end

    context 'when missing dynamic_field_group' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, dynamic_field_group: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Dynamic field group is required'
      end
    end

    context 'when creating select dynamic field' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: DynamicField::Type::SELECT) }

      it 'requires select_options' do
        expect(dynamic_field.save).to be false
        expect(dynamic_field.errors.full_messages).to include 'Select options can\'t be blank'
      end
    end

    context 'when creating a textarea dynamic field' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: DynamicField::Type::TEXTAREA, is_facetable: true) }

      it 'requires is_facetable to be false' do
        expect(dynamic_field.save).to be false
        expect(dynamic_field.errors.full_messages).to include 'Is facetable cannot be true for textareas'
      end
    end

    context 'when creating controlled term dynamic field' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, controlled_vocabulary: nil) }

      it 'requires controlled_vocabulary' do
        expect(dynamic_field.save).to be false
        expect(dynamic_field.errors.full_messages).to include 'Controlled vocabulary can\'t be blank'
      end
    end

    context 'when missing sort_order' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, sort_order: nil) }
      let(:parent) { dynamic_field.dynamic_field_group }

      context 'and has no sibling' do
        before { dynamic_field.save }

        it 'sets sort_order to 0' do
          expect(dynamic_field.sort_order).to be 0
        end
      end

      context 'and has sibling' do
        before do
          FactoryBot.create(:dynamic_field, string_key: 'primary', dynamic_field_group: parent, sort_order: 14)
          FactoryBot.create(:dynamic_field_group, :child, parent: parent, sort_order: 5)
          parent.reload
          dynamic_field.save
        end

        it 'sets sort_order to one more than the highest sort order' do
          expect(dynamic_field.sort_order).to be 15
        end
      end
    end

    context 'when creating a field with the same name as a sibling' do
      let(:parent) { FactoryBot.create(:dynamic_field_group) }

      context 'and the sibling is a DynamicField' do
        let(:dynamic_field) { FactoryBot.build(:dynamic_field, dynamic_field_group: parent) }

        before do
          FactoryBot.create(:dynamic_field, dynamic_field_group: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field.save).to be false
        end

        it 'returns correct error' do
          dynamic_field.save
          expect(dynamic_field.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end

      context 'and the sibling is a DynamicFieldGroup' do
        let(:dynamic_field) { FactoryBot.build(:dynamic_field, string_key: 'role', dynamic_field_group: parent) }

        before do
          FactoryBot.create(:dynamic_field_group, :child, parent: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field.save).to be false
        end

        it 'returns correct error' do
          dynamic_field.save
          expect(dynamic_field.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end
    end
  end

  describe '#siblings' do
    subject(:dynamic_field) { FactoryBot.create(:dynamic_field) }

    it 'does not include current object' do
      dynamic_field.reload
      expect(dynamic_field.siblings).to match_array []
    end
  end

  describe '#path' do
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
    it 'is derived from ancestor path' do
      expect(dynamic_field.path).to eql("#{dynamic_field.parent&.path}/#{dynamic_field.string_key}")
    end
    it 'is unique' do
      expect {
        FactoryBot.create(:dynamic_field, string_key: dynamic_field.string_key, parent: dynamic_field.parent)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'is unique against cross-type siblings' do
      expect {
        FactoryBot.create(:dynamic_field, string_key: dynamic_field.dynamic_field_group.string_key, dynamic_field_group: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    context 'when string_key is updated' do
      let(:old_string_key) { dynamic_field.string_key }
      let(:new_string_key) { "#{old_string_key}_suffix" }
      it 'updates the path' do
        expected = "#{dynamic_field.parent.string_key}/#{new_string_key}"
        dynamic_field.string_key = new_string_key
        dynamic_field.save
        expect(dynamic_field.path).to eql(expected)
      end
      it 'submits an update/reindexing job for the previous path' do
        old_path = dynamic_field.path
        changes = { old_path => old_path.sub(old_string_key, new_string_key) }
        expect(ChangeDynamicFieldPathsJob).to receive(:perform).with(changes)
        dynamic_field.string_key = new_string_key
        dynamic_field.save
      end
    end
  end

  describe '.find_by_path_traversal' do
    let(:field_definitions) do
      {
        dynamic_field_categories: [
          {
            display_label: 'Sample Dynamic Field Category',
            dynamic_field_groups: [
              {
                string_key: 'group1',
                display_label: 'Group 1',
                dynamic_fields: [
                  { string_key: 'string_field', display_label: 'String Field', field_type: DynamicField::Type::STRING },
                  { string_key: 'integer_field', display_label: 'Integer Field', field_type: DynamicField::Type::INTEGER }
                ]
              },
              {
                string_key: 'group2',
                display_label: 'Group 2',
                dynamic_fields: [
                  { string_key: 'string_field', display_label: 'String Field', field_type: DynamicField::Type::STRING },
                  { string_key: 'integer_field', display_label: 'Integer Field', field_type: DynamicField::Type::INTEGER }
                ]
              },
              {
                string_key: 'group3',
                display_label: 'Group 3',
                dynamic_field_groups: [
                  {
                    string_key: 'group3_1',
                    display_label: 'Group 3.1',
                    dynamic_fields: [
                      { string_key: 'string_field', display_label: 'String Field', field_type: DynamicField::Type::STRING },
                      { string_key: 'integer_field', display_label: 'Integer Field', field_type: DynamicField::Type::INTEGER }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    end
    before do
      Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions, load_vocabularies: true)
    end

    it 'finds existing fields' do
      expect(DynamicField.find_by_path_traversal(['group1', 'string_field']).path).to eq('group1/string_field')
      expect(DynamicField.find_by_path_traversal(['group1', 'integer_field']).path).to eq('group1/integer_field')
      expect(DynamicField.find_by_path_traversal(['group2', 'string_field']).path).to eq('group2/string_field')
      expect(DynamicField.find_by_path_traversal(['group2', 'integer_field']).path).to eq('group2/integer_field')
      expect(DynamicField.find_by_path_traversal(['group3', 'group3_1', 'string_field']).path).to eq('group3/group3_1/string_field')
      expect(DynamicField.find_by_path_traversal(['group3', 'group3_1', 'integer_field']).path).to eq('group3/group3_1/integer_field')
    end

    it 'raises an error for impossible paths' do
      expect { DynamicField.find_by_path_traversal(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { DynamicField.find_by_path_traversal(['there_are_no_top_level_fields']) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error for a field that cannot be found' do
      expect { DynamicField.find_by_path_traversal(['group1234567', 'string_field']) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
