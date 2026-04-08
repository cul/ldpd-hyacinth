require 'rails_helper'

describe "Adding and removing child objects" do
  let(:minimal_item_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/minimal_item.json').read )
    dod['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    dod
  }

  let(:sample_asset_digital_object_data) do
    dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
    dod['publish_targets'] = []
    dod['import_file']['main']['import_type'] = 'internal'
    dod['import_file']['main']['import_location'] = fixture('sample_assets/sample_text_file.txt').path
    dod
  end

  before do
    @item1 = DigitalObjectType.get_model_for_string_key(minimal_item_digital_object_data['digital_object_type']['string_key']).new()
    @item1.set_digital_object_data(minimal_item_digital_object_data, false)
    @item1.save

    @item2 = DigitalObjectType.get_model_for_string_key(minimal_item_digital_object_data['digital_object_type']['string_key']).new()
    @item2.set_digital_object_data(minimal_item_digital_object_data, false)
    @item2.save

    @asset1 = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
    @asset1.set_digital_object_data(sample_asset_digital_object_data, false)
    @asset1.save

    @asset2 = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
    @asset2.set_digital_object_data(sample_asset_digital_object_data, false)
    @asset2.save
  end

  context "adding parent objects" do
    it "properly updates bidirectional parent-child relationships" do
      # Initially, the assets should have no parents
      expect(@asset1.parent_digital_object_pids).to eq([])
      expect(@asset2.parent_digital_object_pids).to eq([])
      # And the items should have no children
      expect(@item1.ordered_child_digital_object_pids).to eq([])
      expect(@item2.ordered_child_digital_object_pids).to eq([])

      # Add parents
      @asset1.add_parent_digital_object(@item1)
      @asset1.add_parent_digital_object(@item2)
      @asset1.save
      @asset2.add_parent_digital_object(@item1)
      @asset2.add_parent_digital_object(@item2)
      @asset2.save

      # Current asset instance parents should be correct
      expect(@asset1.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])
      expect(@asset2.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])

      # Current item instances will NOT be updated unless the items are reloaded,
      # so we would expect the current item instance children to be empty.
      expect(@item1.ordered_child_digital_object_pids).to eq([])
      expect(@item2.ordered_child_digital_object_pids).to eq([])

      # Reloaded asset instance parents should be correct
      @asset1 = DigitalObject::Base.find(@asset1.pid)
      @asset2 = DigitalObject::Base.find(@asset2.pid)
      expect(@asset1.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])
      expect(@asset2.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])

      # Reloaded item children should be correct
      @item1 = DigitalObject::Base.find(@item1.pid)
      @item2 = DigitalObject::Base.find(@item1.pid)
      expect(@item1.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])
      expect(@item2.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])
    end
  end

  context "removing parent objects" do
    before do
      # Add parent-child relationships and reload objects so our upcoming test will simulate
      # existing records that had previously-assigned parent-child relationships.
      @asset1.add_parent_digital_object(@item1)
      @asset1.add_parent_digital_object(@item2)
      expect(@asset1.save).to eq(true)
      @asset2.add_parent_digital_object(@item1)
      @asset2.add_parent_digital_object(@item2)
      expect(@asset2.save).to eq(true)

      # Reload assets
      @asset1 = DigitalObject::Base.find(@asset1.pid)
      @asset2 = DigitalObject::Base.find(@asset2.pid)

      # Reload items
      @item1 = DigitalObject::Base.find(@item1.pid)
      @item2 = DigitalObject::Base.find(@item2.pid)
    end

    it "properly updates bidirectional parent-child relationships" do
      # We expect the assets to start off with parents
      expect(@asset1.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])
      expect(@asset2.parent_digital_object_pids).to eq([@item1.pid, @item2.pid])

      # We expect the items to start off with children
      expect(@item1.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])
      expect(@item2.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])

      # Remove parents
      @asset1.remove_parent_digital_object_by_pid(@item1.pid)
      @asset1.remove_parent_digital_object_by_pid(@item2.pid)
      @asset1.save
      @asset2.remove_parent_digital_object_by_pid(@item1.pid)
      @asset2.remove_parent_digital_object_by_pid(@item2.pid)
      @asset2.save

      # Current asset instance parents should be correct
      expect(@asset1.parent_digital_object_pids).to eq([])
      expect(@asset2.parent_digital_object_pids).to eq([])

      # Current item instances will NOT be updated unless the items are reloaded,
      # so we would expect the current item instance children to be empty.
      expect(@item1.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])
      expect(@item2.ordered_child_digital_object_pids).to eq([@asset1.pid, @asset2.pid])

      # Reload item instances
      @item1 = DigitalObject::Base.find(@item1.pid)
      @item2 = DigitalObject::Base.find(@item2.pid)

      # Now we expect the item instances to have the correct children
      expect(@item1.ordered_child_digital_object_pids).to eq([])
      expect(@item2.ordered_child_digital_object_pids).to eq([])
    end
  end
end
