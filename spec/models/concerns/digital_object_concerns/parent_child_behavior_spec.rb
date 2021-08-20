# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::ParentChildBehavior, solr: true do
  let(:item1) { FactoryBot.create(:item) }
  let(:item2) { FactoryBot.create(:item) }
  let(:asset1) { FactoryBot.create(:asset, :with_main_resource) }
  let(:asset2) { FactoryBot.create(:asset, :with_main_resource) }

  context 'adding children' do
    before do
      expect(item1.children).to be_empty
      item1.children_to_add << asset1
      item1.children_to_add << asset2
      expect(item1.children).to be_empty # expect empty because additions aren't persisted until save
    end

    it 'persists updates only after successful digital object save' do
      expect(item1.save).to eq(true)
      expect(item1.children.length).to eq(2) # proof that update was applied to instance
      expect(DigitalObject.find(item1.id).children.length).to eq(2) # proof that update was persisted
      expect(item1.children_to_add).to be_empty # pending updates are cleared because save succeeded
    end

    it 'does not persist updates when digital object save fails' do
      item1.state = nil
      expect(item1.save).to eq(false)
      expect(item1.errors.attribute_names).to eq([:state])
      expect(item1.children.length).to eq(0) # proof that update was NOT applied to instance
      expect(DigitalObject.find(item1.id).children.length).to eq(0) # proof that update was NOT persisted
      expect(item1.children_to_add.length).to eq(2) # pending updates remain because save failed
    end

    context 'order of children for added children' do
      before { item1.save }
      it 'preserves child addition order after a successful save' do
        expect(item1.children).to eq([asset1, asset2])
      end
    end
  end

  context 'removing children' do
    before do
      item1.children_to_add << asset1
      item1.children_to_add << asset2
      item1.save
      expect(item1.children.length).to eq(2)
      item1.children_to_remove << asset1
      item1.children_to_remove << asset2
    end

    it 'persists updates only after successful digital object save' do
      expect(item1.save).to eq(true)
      expect(item1.children).to be_empty # proof that update was applied to instance
      expect(DigitalObject.find(item1.id).children.length).to eq(0) # proof that update was persisted
      expect(item1.children_to_remove).to be_empty # pending updates are cleared because save succeeded
    end

    it 'does not persist updates when digital object save fails' do
      item1.state = nil
      expect(item1.save).to eq(false)
      expect(item1.errors.attribute_names).to eq([:state])
      expect(item1.children.length).to eq(2) # proof that update was NOT applied to instance
      expect(DigitalObject.find(item1.id).children.length).to eq(2) # proof that update was NOT persisted
      expect(item1.children_to_remove.length).to eq(2) # pending updates are NOT cleared because save failed
    end
  end

  context 'adding parents' do
    before do
      expect(asset1.parents).to be_empty
      asset1.parents_to_add << item1
      asset1.parents_to_add << item2
      expect(asset1.parents).to be_empty # expect empty because additions aren't persisted until save
    end

    it 'persists updates only after successful digital object save' do
      expect(asset1.save).to eq(true)
      expect(asset1.parents.length).to eq(2) # proof that update was applied to instance
      expect(DigitalObject.find(asset1.id).parents.length).to eq(2) # proof that update was persisted
      expect(asset1.parents_to_add).to be_empty # pending updates are cleared because save succeeded
    end

    it 'does not persist updates when digital object save fails' do
      asset1.state = nil
      expect(asset1.save).to eq(false)
      expect(asset1.errors.attribute_names).to eq([:state])
      expect(asset1.parents.length).to eq(0) # proof that update was NOT applied to instance
      expect(DigitalObject.find(asset1.id).parents.length).to eq(0) # proof that update was NOT persisted
      expect(asset1.parents_to_add.length).to eq(2) # pending updates remain because save failed
    end

    context 'order of children for added parents' do
      before do
        asset2.parents_to_add << item1
        asset2.parents_to_add << item2
        asset1.save
        asset2.save
        item1.reload
        item2.reload
      end
      it 'preserves child addition order after a successful save' do
        expect(item1.children).to eq([asset1, asset2])
        expect(item2.children).to eq([asset1, asset2])
      end
    end
  end

  context 'removing parents' do
    before do
      asset1.parents_to_add << item1
      asset1.parents_to_add << item2
      asset1.save
      expect(asset1.parents.length).to eq(2)
      asset1.parents_to_remove << item1
      asset1.parents_to_remove << item2
    end

    it 'persists updates only after successful digital object save' do
      expect(asset1.save).to eq(true)
      expect(asset1.parents).to be_empty # proof that update was applied to instance
      expect(DigitalObject.find(asset1.id).parents.length).to eq(0) # proof that update was persisted
      expect(asset1.parents_to_remove).to be_empty # pending updates are cleared because save succeeded
    end

    it 'does not persist updates when digital object save fails' do
      asset1.state = nil
      expect(asset1.save).to eq(false)
      expect(asset1.errors.attribute_names).to eq([:state])
      expect(asset1.parents.length).to eq(2) # proof that update was NOT applied to instance
      expect(DigitalObject.find(asset1.id).parents.length).to eq(2) # proof that update was NOT persisted
      expect(asset1.parents_to_remove.length).to eq(2) # pending updates are NOT cleared because save failed
    end
  end

  describe '#remove_all_parents!' do
    before do
      asset1.parents_to_add << item1
      asset1.parents_to_add << item2
      asset1.save
      expect(asset1.parents.length).to eq(2)
    end

    it 'works as expected' do
      asset1.remove_all_parents!
      expect(asset1.parents.length).to eq(0)
    end
  end

  describe '#remove_all_children!' do
    before do
      item1.children_to_add << asset1
      item1.children_to_add << asset2
      item1.save
      expect(item1.children.length).to eq(2)
    end

    it 'works as expected' do
      item1.remove_all_children!
      expect(item1.children.length).to eq(0)
    end
  end
end
