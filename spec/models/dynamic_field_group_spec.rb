# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamicFieldGroup, type: :model do
  describe '#new' do
    context 'when parameters correct' do
      subject { FactoryBot.create(:dynamic_field_group) }

      it { is_expected.to be_a DynamicFieldGroup }

      its(:string_key)    { is_expected.to eql 'name' }
      its(:path)          { is_expected.to eql 'name' }
      its(:display_label) { is_expected.to eql 'Name' }
      its(:is_repeatable) { is_expected.to be true }
      its(:sort_order)    { is_expected.to be 3 }
      its(:parent)        { is_expected.to be_a DynamicFieldCategory }
      its(:created_by)    { is_expected.to be_a User }
      its(:updated_by)    { is_expected.to be_a User }
    end

    context 'when missing string_key' do
      let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, string_key: nil) }

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when setting invalid string_key' do
      let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, string_key: 'URL') }

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'String key values must be up to 240 characters long, start with a lowercase letter, groupings of lowercase letters and numbers can be seperated by ONE underscore'
      end
    end

    context 'when setting to reserved string_key' do
      let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, string_key: 'uri') }

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'String key is reserved'
      end
    end

    context 'when missing parent' do
      let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, parent: nil) }

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'Parent is required'
      end
    end

    context 'when sort order is missing' do
      let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group, parent: parent, sort_order: nil) }

      context 'and parent is a dynamic field category' do
        let(:parent) { FactoryBot.create(:dynamic_field_category) }

        context 'and there other top level groups' do
          before do
            FactoryBot.create(:dynamic_field_group, string_key: 'title', parent: parent, sort_order: 4)
            FactoryBot.create(:dynamic_field_group, string_key: 'abstract', parent: parent, sort_order: 15)
            parent.reload
          end

          it 'sets sort order to one more than the highest sort order of any top level group' do
            expect(dynamic_field_group.sort_order).to be 16
          end
        end

        context 'and there are no other top level groups' do
          it 'sets sort order to 0' do
            expect(dynamic_field_group.sort_order).to be 0
          end
        end
      end

      context 'and parent is a dynamic field group' do
        let(:parent) { FactoryBot.create(:dynamic_field_group, string_key: 'all_names') }

        context 'and other siblings are present' do
          before do
            FactoryBot.create(:dynamic_field_group, :child, parent: parent, sort_order: 9)
            FactoryBot.create(:dynamic_field, string_key: 'type', dynamic_field_group: parent, sort_order: 16)
            parent.reload
          end

          it 'sets sort order to one more than the higest sort order of any sibling' do
            expect(dynamic_field_group.sort_order).to be 17
          end
        end

        context 'and no other sublings are present' do
          it 'sets sort order to 0' do
            expect(dynamic_field_group.sort_order).to be 0
          end
        end
      end
    end

    context 'when creating a group with the same string_key as a sibling' do
      context 'and the sibiling is a dynamic_field' do
        let(:parent) { FactoryBot.create(:dynamic_field_group) }
        let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, :child, parent: parent) }

        before do
          FactoryBot.create(:dynamic_field, string_key: 'role', dynamic_field_group: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field_group.save).to be false
        end

        it 'returns correct error' do
          dynamic_field_group.save
          expect(dynamic_field_group.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end

      context 'and the sibiling is a dynamic_field_group' do
        let(:parent) { FactoryBot.create(:dynamic_field_category) }
        let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, string_key: 'name', parent: parent) }

        before do
          FactoryBot.create(:dynamic_field_group, string_key: 'name', parent: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field_group.save).to be false
        end

        it 'returns correct error' do
          dynamic_field_group.save
          expect(dynamic_field_group.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end
    end

    context 'when creating a group that shares the same string_key as a non-sibling group' do
      let(:parent1) { FactoryBot.create(:dynamic_field_category, display_label: 'DFC 1') }
      let(:parent2) { FactoryBot.create(:dynamic_field_category, display_label: 'DFC 2') }
      let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, string_key: 'name', parent: parent1) }

      it 'saves the object' do
        expect(dynamic_field_group.save).to be true
      end

      context 'and the sibiling is a dynamic_field_group, even across dynamic field categories' do
        before do
          FactoryBot.create(:dynamic_field_group, string_key: 'name', parent: parent2)
        end
        it 'does not save' do
          expect(dynamic_field_group.save).to be false
        end
        it 'returns correct error' do
          dynamic_field_group.save
          expect(dynamic_field_group.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end
    end
  end

  describe '#parent' do
    let(:dynamic_field_group) { FactoryBot.build(:dynamic_field_group, :child) }

    before do
      dynamic_field_group.parent = parent
      dynamic_field_group.save
      parent.reload
    end

    context 'when setting DynamicFieldCategory as parent' do
      let(:parent) { FactoryBot.create(:dynamic_field_category) }

      it 'adds parent' do
        expect(dynamic_field_group.parent).to eq parent
      end

      it 'adds dynamic field group to dynamic field category' do
        expect(parent.dynamic_field_groups).to match_array [dynamic_field_group]
      end
    end

    context 'when setting DynamicFieldGroup as parent' do
      let(:parent) { FactoryBot.create(:dynamic_field_group) }

      it 'adds parent' do
        expect(dynamic_field_group.parent).to eq parent
      end

      it 'adds dynamic field group to parent dynamic field group' do
        expect(parent.dynamic_field_groups).to match_array [dynamic_field_group]
      end
    end

    context 'when setting itself as parent' do
      let(:parent) { FactoryBot.create(:dynamic_field_category) }

      before do
        dynamic_field_group.parent = dynamic_field_group
      end

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'Parent cannot be self'
      end
    end

    context 'when setting parent to invalid parent type' do
      let(:parent) { FactoryBot.create(:user, email: 'random_user@example.com') }

      it 'does not save' do
        expect(dynamic_field_group.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_group.save
        expect(dynamic_field_group.errors.full_messages).to include 'Parent type is not among the list of allowed values'
      end
    end
  end

  describe '#dynamic_fields' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }
    let(:dynamic_field_1) { FactoryBot.build(:dynamic_field, dynamic_field_group: nil) }
    let(:dynamic_field_2) { FactoryBot.build(:dynamic_field, dynamic_field_group: nil, string_key: 'usage_primary') }

    it 'can add a dynamic field' do
      dynamic_field_group.dynamic_fields << dynamic_field_1
      dynamic_field_group.save!
      dynamic_field_group.reload

      expect(dynamic_field_group.dynamic_fields).to match_array [dynamic_field_1]
      expect(dynamic_field_group.dynamic_fields.map(&:path).sort).to match_array ["name/term"]
    end

    it 'can add multiple dynamic fields' do
      dynamic_field_group.dynamic_fields << dynamic_field_1
      dynamic_field_group.dynamic_fields << dynamic_field_2
      dynamic_field_group.save && dynamic_field_group.reload
      expect(dynamic_field_group.dynamic_fields).to match_array [dynamic_field_1, dynamic_field_2]
      expect(dynamic_field_group.dynamic_fields.map(&:path).sort).to match_array ["name/term", "name/usage_primary"]
    end
  end

  describe '#dynamic_field_groups' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group, string_key: 'name') }
    let(:child) { FactoryBot.build(:dynamic_field_group, :child) }

    before do
      dynamic_field_group.dynamic_field_groups << child
      dynamic_field_group.save
    end

    it 'can add a dynamic_field_group' do
      expect(dynamic_field_group.dynamic_field_groups).to include child
      expect(child.parent).to be dynamic_field_group
    end
  end

  describe '#children' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }
    let(:child_group) { FactoryBot.build(:dynamic_field_group, :child) }
    let(:child_field) { FactoryBot.build(:dynamic_field, dynamic_field_group: false) }

    before do
      child_group.parent = dynamic_field_group
      child_group.save
      child_field.dynamic_field_group = dynamic_field_group
      child_field.save
      dynamic_field_group.reload
    end

    it 'returns child dynamic_field_group' do
      expect(dynamic_field_group.children).to include child_group
    end

    it 'returns child dynamic_field' do
      expect(dynamic_field_group.children).to include child_field
    end
  end

  describe '#ordered_children' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }
    let(:child_group) { FactoryBot.create(:dynamic_field_group, :child, parent: dynamic_field_group) }
    let(:child_field_1) { FactoryBot.create(:dynamic_field, string_key: 'type', dynamic_field_group: dynamic_field_group) }
    let(:child_field_2) { FactoryBot.create(:dynamic_field, dynamic_field_group: dynamic_field_group) }

    before do
      child_field_2
      child_field_1
      child_group
      dynamic_field_group.reload
    end

    it 'returns all children in correct order' do
      expect(dynamic_field_group.ordered_children).to match [child_group, child_field_2, child_field_1]
    end
  end

  describe '#siblings' do
    subject(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

    it 'does not include current object' do
      dynamic_field_group.reload
      expect(dynamic_field_group.siblings).to match_array []
    end
  end

  describe '#path' do
    subject(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }
    it 'is derived from ancestor path' do
      expect(dynamic_field_group.path).to eql(dynamic_field_group.string_key.to_s)
    end
    it 'is unique' do
      expect {
        FactoryBot.create(:dynamic_field_group, string_key: dynamic_field_group.string_key, parent: dynamic_field_group.parent)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'is unique against cross-type siblings' do
      field = FactoryBot.create(:dynamic_field, dynamic_field_group: dynamic_field_group)
      expect {
        FactoryBot.create(:dynamic_field_group, string_key: field.string_key, parent: dynamic_field_group)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    context 'when string_key is updated' do
      let(:old_string_key) { dynamic_field_group.string_key }
      let(:new_string_key) { "#{old_string_key}_suffix" }
      let(:dynamic_field) { FactoryBot.create(:dynamic_field, dynamic_field_group: dynamic_field_group, display_label: "Dynamic Field Display Label") }
      it 'updates the path' do
        dynamic_field_group.string_key = new_string_key
        expect(dynamic_field_group.save).to eq(true)
        dynamic_field_group.reload
        expect(dynamic_field_group.path).to eql(new_string_key)
      end
      it 'updates the paths of descendants' do
        dynamic_field_group.string_key = new_string_key
        expect(dynamic_field_group.save).to eq(true)
        new_path = DynamicField.find(dynamic_field.id).path
        expect(new_path).to start_with(dynamic_field_group.path)
      end
      it 'submits an update/reindexing job for the previous path' do
        old_path = dynamic_field_group.path
        changes = { old_path => old_path.sub(old_string_key, new_string_key) }
        expect(ChangeDynamicFieldPathsJob).to receive(:perform_later).with(changes)
        dynamic_field_group.string_key = new_string_key
        expect(dynamic_field_group.save).to eq(true)
      end
    end
  end
end
