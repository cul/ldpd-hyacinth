# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DestroyBehavior, solr: true do
  let(:digital_object_with_sample_data) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }

  context "#purge!" do
    context "destroys first" do
      it "calls the destroy! method internally" do
        expect(digital_object_with_sample_data).to receive(:destroy!)
        digital_object_with_sample_data.purge!
      end
    end

    context "successful run" do
      let!(:object_uid) { digital_object_with_sample_data.uid }
      let!(:metadata_location_uri) { digital_object_with_sample_data.digital_object_record.metadata_location_uri }
      let!(:purge_result) do
        digital_object_with_sample_data.purge!
      end

      it "returns true" do
        expect(purge_result).to be true
      end

      it "deletes the object's metadata from metadata storage" do
        expect(Hyacinth::Config.metadata_storage.exists?(metadata_location_uri)).to eq(false)
      end

      it "deletes the object's associated DigitalObjectRecord" do
        expect(DigitalObjectRecord.exists?(uid: object_uid)).to eq(false)
      end
    end

    it "runs the expected on_purge callbacks" do
      expect(digital_object_with_sample_data).to receive(:deindex)
      digital_object_with_sample_data.purge!
    end
  end
end
