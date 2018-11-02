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

  context "uploads of unicode file data with BOM" do
    # <BOM>Q: This is Myron
    let(:utf8_source) do
      codepoints = [239,187,191,81,58,32,84,104,105,115,32,105,115,32,77,121,114,111,110]
      seed = ""
      seed.force_encoding(Encoding::ASCII_8BIT)
      codepoints.inject(seed) { |m,c| m << c }
    end
    subject { DigitalObject::Asset.new.encoded_string(utf8_source) }
    # it is UTF8
    it { expect(subject.encoding).to eql(Encoding::UTF_8) }
    # it removes the BOM
    it { expect(subject.codepoints).to eql("Q: This is Myron".codepoints) }
  end
end
