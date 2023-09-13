require 'rails_helper'

RSpec.describe DigitalObject::Asset, :type => :model do
  context "checksum storage and retrieval" do
    let(:digital_object_data) {
      dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
      dod['publish_targets'] = []
      dod['import_file']['import_type'] = 'external'
      dod['import_file']['import_path'] = fixture('sample_assets/sample_text_file.txt').path
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
      digital_object_data['import_file']['import_path'] = fixture('sample_assets/empty_file.txt').path
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

  context "uploads of file data" do
    context "in utf8 with BOM" do
      include_context 'utf bom example source'
      let(:prefix) { DigitalObject::Asset::BOM_UTF_8 }
      # <BOM>Q: This is Myrön
      let(:input_source) { prefix + utf8_source }
      include_examples "strips BOM and returns UTF8"
    end
    context "in utf8 without BOM" do
      include_context 'utf bom example source'
      let(:input_source) { utf8_source }
      include_examples "strips BOM and returns UTF8"
    end
    context "in utf16-BE with BOM" do
      include_context 'utf bom example source'
      let(:prefix) { DigitalObject::Asset::BOM_UTF_16BE }
      let(:input_source) { prefix + utf8_target.encode(Encoding::UTF_16BE).b }
      include_examples "strips BOM and returns UTF8"
    end
    context "in ISO-8859-1" do
      include_context 'utf bom example source'
      let(:input_source) { utf8_target.encode(Encoding::ISO_8859_1).b }
      include_examples "strips BOM and returns UTF8"
    end
  end
  describe 'featured_region' do
    let(:well_known_pid) { 'some:asset' }
    let(:content_ds_uri) { "info:fedora/#{well_known_pid}/content" }
    let(:content_ds) { ActiveFedora::Datastream.new(generic_resource, 'content') }
    let(:asset) { DigitalObject::Asset.new }
    let(:generic_resource) { GenericResource.new(pid: well_known_pid) }
    let(:image_width) { 3000 }
    let(:image_length) { 4000 }
    let(:region_right) { 100 }
    let(:region_width) { image_width - region_right }
    let(:region_bottom) { image_length - region_width }
    let(:good_region) { "0,0,#{region_width},#{region_width}" }
    let(:good_if_rotated_region) { "#{image_length - image_width},0,#{region_width},#{region_width}" }
    before do
      generic_resource.add_datastream(content_ds)
      asset.instance_variable_set(:@fedora_object, generic_resource)
    end
    shared_examples "a region validator" do
      it "is valid with good region" do
        asset.featured_region = good_region
        asset.validate_featured_region
        expect(asset.errors).to be_empty
      end
      it "is valid with good region contingent on rotation" do
        asset.featured_region = good_if_rotated_region
        generic_resource.orientation = 90
        asset.validate_featured_region
        expect(asset.errors).to be_empty
      end
      it "is not valid with bad region" do
        asset.featured_region = good_if_rotated_region
        asset.validate_featured_region
        expect(asset.errors).not_to be_empty
      end
      it "rotates a region appropriately when image is rotated" do
        asset.featured_region = good_region
        region_params = good_region.split(',')
        # get a rotated value for 90 more degrees
        rotated_region = asset.rotated_region(90)
        expect(rotated_region).to eql("#{region_bottom},#{region_params[0]},#{region_width},#{region_width}")
        rotated_region = asset.rotated_region(180)
        expect(rotated_region).to eql("#{region_right},#{region_bottom},#{region_width},#{region_width}")
        rotated_region = asset.rotated_region(270)
        expect(rotated_region).to eql("#{0},#{region_right},#{region_width},#{region_width}")
        asset.featured_region = rotated_region
        generic_resource.orientation = 270
        asset.validate_featured_region
        expect(asset.errors).to be_empty
      end
    end
    context "asset had RELS-EXT width and length" do
      before do
        generic_resource.add_relationship(:image_width, image_width, true)
        generic_resource.add_relationship(:image_length, image_length, true)
      end
      it_behaves_like "a region validator"
    end
    context "asset had RELS-INT width and length" do
      before do
        generic_resource.rels_int.add_relationship(content_ds, :image_width, image_width, true)
        generic_resource.rels_int.add_relationship(content_ds, :image_length, image_length, true)
      end
      it_behaves_like "a region validator"
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
end
