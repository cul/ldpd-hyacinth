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
end
