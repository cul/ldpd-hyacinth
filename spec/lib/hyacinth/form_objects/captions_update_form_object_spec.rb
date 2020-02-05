require 'rails_helper'

describe Hyacinth::FormObjects::CaptionsUpdateFormObject do
  let(:format_prefix) { "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\n".encode(Encoding::UTF_8) }
  context "UTF data" do
    context "in utf8 with BOM" do
      include_context 'utf bom example source'
      let(:prefix) { Hyacinth::FormObjects::CaptionsUpdateFormObject::BOM_UTF_8 }
      # <BOM>Q: This is Myrön
      let(:input_source) { prefix + utf8_source }
      include_examples "strips BOM and returns UTF8"
    end
    context "in utf8 without BOM" do
      include_context 'utf bom example source'
      let(:input_source) { utf8_source }
      include_examples "strips BOM and returns UTF8"
    end
  end
  describe "#captions_content" do
    include_context 'utf bom example source'
    subject { described_class.new }
    before { subject.captions_vtt = format_prefix + utf8_source }
    it "strips BOM and returns UTF8" do
      expect(subject.captions_content).to eql(format_prefix + utf8_target)
    end
  end
  describe "#valid_webvtt?" do
    subject { described_class.new }
    include_context 'utf bom example source'
    context "with web vtt content" do
      before { subject.captions_vtt = format_prefix + utf8_source }
      it "validates" do
        expect(subject.valid?).to be true
      end
    end
    context "with plain text content" do
      before { subject.captions_vtt = utf8_source }
      it "does not validates" do
        expect(subject.valid?).to be false
      end
    end
  end
end
