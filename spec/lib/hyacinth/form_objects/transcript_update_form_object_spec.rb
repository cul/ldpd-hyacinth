require 'rails_helper'

describe Hyacinth::FormObjects::TranscriptUpdateFormObject do
  context "UTF data" do
    context "in utf8 with BOM" do
      include_context 'utf bom example source'
      let(:prefix) { Hyacinth::FormObjects::TranscriptUpdateFormObject::BOM_UTF_8 }
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
      let(:prefix) { Hyacinth::FormObjects::TranscriptUpdateFormObject::BOM_UTF_16BE }
      let(:input_source) { prefix + utf8_target.encode(Encoding::UTF_16BE).b }
      include_examples "strips BOM and returns UTF8"
    end
    context "in ISO-8859-1" do
      include_context 'utf bom example source'
      let(:input_source) { utf8_target.encode(Encoding::ISO_8859_1).b }
      include_examples "strips BOM and returns UTF8"
    end
  end
  describe "#transcript_content" do
    include_context 'utf bom example source'
    subject { described_class.new }
    before { subject.transcript_text = utf8_source }
    it "strips BOM and returns UTF8" do
      expect(subject.transcript_content).to eql(utf8_target)
    end
  end
end
