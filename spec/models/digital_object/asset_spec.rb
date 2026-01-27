require 'rails_helper'

RSpec.describe DigitalObject::Asset, :type => :model do
  context "checksum storage and retrieval" do
    let(:digital_object_data) {
      dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
      dod['publish_targets'] = []
      dod['import_file']['main']['import_type'] = 'external'
      dod['import_file']['main']['import_location'] = fixture('sample_assets/sample_text_file.txt').path
      dod
    }

    it "returns an error when the uploaded file is 0 bytes" do
      asset = DigitalObject::Asset.new
      allow(asset).to receive(:allowed_publish_targets).and_return([])
      allow(asset).to receive(:next_pid).and_return('some:pid')
      allow(asset).to receive(:set_data_to_sources).and_return(nil)
      allow_any_instance_of(DigitalObjectRecord).to receive(:save!).and_return(true)
      allow_any_instance_of(GenericResource).to receive(:save).and_return(true)
      allow(asset).to receive(:update_index).and_return(nil)
      digital_object_data['import_file']['main']['import_location'] = fixture('sample_assets/empty_file.txt').path
      asset.set_digital_object_data(digital_object_data, false)
      save_result = asset.save
      expect(asset.errors.messages).to eq({import_file: ['Original file file size is 0 bytes. File must contain data.']})
      expect(save_result).to eq(false)
    end

    it "stores an asset's checksum in :has_message_digest relationship on the 'content' datastream, and can retrieve that checksum using the #checksum method" do
      asset = DigitalObject::Asset.new
      allow(asset).to receive(:allowed_publish_targets).and_return([])
      allow(asset).to receive(:next_pid).and_return('some:pid')
      allow(asset).to receive(:set_data_to_sources).and_return(nil)
      allow_any_instance_of(DigitalObjectRecord).to receive(:save!).and_return(true)
      allow_any_instance_of(GenericResource).to receive(:save).and_return(true)
      allow_any_instance_of(UpdateImageServiceJob).to receive(:perform)
      allow(asset).to receive(:update_index).and_return(nil)
      asset.set_digital_object_data(digital_object_data, false)
      asset.save
      content_ds = asset.fedora_object.datastreams['content']
      expect(content_ds).to be_present
      expect(asset.fedora_object.rels_int.relationships(content_ds, :has_message_digest).length).to eq(1)

      # Expect value to be stored in fedora object's RELS-INT for content datastream
      expect(asset.fedora_object.rels_int.relationships(content_ds, :has_message_digest).first.object.value).to eq('urn:sha256:5bd846648fab9a3871ef82b5d58ca965be2c15ee8a16855119e1db7c7465b110')

      # Expect to be able to retrieve value via DigitalObject::Asset#checksum method (without 'urn:' prefix)
      expect(asset.checksum).to eq('sha256:5bd846648fab9a3871ef82b5d58ca965be2c15ee8a16855119e1db7c7465b110')
    end

    it "#checksum method return nil when there is no checksum value" do
      asset = DigitalObject::Asset.new
      expect(asset.checksum).to eq(nil)
    end
  end

  describe 'featured_region' do
    let(:well_known_pid) { 'some:asset' }
    let(:generic_resource) { GenericResource.new(pid: well_known_pid) }
    let(:content_ds) { ActiveFedora::Datastream.new(generic_resource, 'content') }
    let(:asset) { DigitalObject::Asset.new }
    let(:region) { '100,150,512,512' }
    let(:bad_region) { 'NOT A VALID REGION' }

    before do
      generic_resource.add_datastream(content_ds)
      asset.instance_variable_set(:@fedora_object, generic_resource)
    end

    describe '#featured_region=' do
      let(:region) { '100,150,512,512'  }
      it "successfully assigns a region" do
        asset.featured_region = region
        expect(generic_resource.relationships(:region_featured).first.object).to eq(region)
      end
    end

    describe '#featured_region' do
      it "successfully returns a previously assigned region" do
        asset.featured_region = region
        expect(asset.featured_region).to eq(region)
      end
    end

    describe 'validation' do
      it 'passes when the region is a good format' do
        asset.featured_region = region
        asset.validate_featured_region_if_present
        expect(asset.errors).to be_empty
      end

      it 'fails when the region is a bad format' do
        asset.featured_region = bad_region
        asset.validate_featured_region_if_present
        expect(asset.errors).to have_key(:featured_region)
      end
    end
  end

  describe 'region_selection_event' do
    let(:well_known_pid) { 'some:asset' }
    let(:test_user) { 'test@hyacinth.org' }
    let(:last_updated) { (Time.now - 1.day).utc }
    let(:digital_object_record) { DigitalObjectRecord.new(updated_at: last_updated) }
    let(:generic_resource) { GenericResource.new(pid: well_known_pid) }
    let(:asset) { DigitalObject::Asset.new }
    let(:rels_ext_value) { asset.fedora_object.relationships(:region_selection_event).first.value }
    before do
      asset.instance_variable_set(:@fedora_object, generic_resource)
      asset.instance_variable_set(:@db_record, digital_object_record)
    end
    it 'falls back to last object update if unassigned' do
      json = asset.region_selection_event
      expect(json['updatedAt']).to eql(last_updated.iso8601)
      expect(json['updatedBy']).to eql("automatic-process@library.columbia.edu")
    end
    context 'is assigned' do
      before do
        asset.region_selection_event = {'updatedBy': test_user}
      end
      it 'serializes to RELS-EXT with a timestamp' do
        json = JSON.load(rels_ext_value)
        expect(json['updatedBy']).to eql(test_user)
        expect(json['updatedAt']).to be_present
      end
    end
  end

  describe '#perform_derivative_processing' do
    it 'defaults to true for a new asset' do
      asset = DigitalObject::Asset.new
      expect(asset.perform_derivative_processing).to eq(true)
    end

    it 'can be set and the set value can be retrieved' do
      asset = DigitalObject::Asset.new
      asset.perform_derivative_processing = false
      expect(asset.perform_derivative_processing).to eq(false)
    end
  end
  describe 'audio_moving_image?' do
    let(:asset) { DigitalObject::Asset.new }
    it "is true when appropriate dc_type value from DC" do
      asset.instance_variable_set(:@dc_type, 'MovingImage')
      expect(asset.audio_moving_image?).to be true
      asset.instance_variable_set(:@dc_type, 'Sound')
      expect(asset.audio_moving_image?).to be true
    end
    it "is false when inappropriate dc_type value from DC" do
      asset.instance_variable_set(:@dc_type, 'Dataset')
      expect(asset.audio_moving_image?).to be false
    end
    it "is true when appropriate dc_type value from PCDM" do
      asset.instance_variable_set(:@dc_type, 'Audio')
      expect(asset.audio_moving_image?).to be true
      asset.instance_variable_set(:@dc_type, 'Video')
      expect(asset.audio_moving_image?).to be true
    end
    it "is false when inappropriate dc_type value from PCDM" do
      asset.instance_variable_set(:@dc_type, 'Spreadsheet')
      expect(asset.audio_moving_image?).to be false
    end
  end
  describe 'still_image?' do
    let(:asset) { DigitalObject::Asset.new }
    it "is true when appropriate dc_type value from DC" do
      asset.instance_variable_set(:@dc_type, 'StillImage')
      expect(asset.still_image?).to be true
    end
    it "is false when inappropriate dc_type value from DC" do
      asset.instance_variable_set(:@dc_type, 'MovingImage')
      expect(asset.still_image?).to be false
    end
    it "is true when appropriate dc_type value from PCDM" do
      asset.instance_variable_set(:@dc_type, 'Image')
      expect(asset.still_image?).to be true
    end
    it "is false when inappropriate dc_type value from PCDM" do
      asset.instance_variable_set(:@dc_type, 'Video')
      expect(asset.still_image?).to be false
    end
  end
end
