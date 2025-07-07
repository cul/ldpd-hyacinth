require 'rails_helper'

describe Hyacinth::FormObjects::CaptionsUpdateFormObject do
  let(:utf8_webvtt_content) { "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\nGood slice of 🍕!" }

  describe "#captions_content" do
    subject { described_class.new }
    before { subject.captions_vtt = utf8_webvtt_content }
    it "returns the previously set utf-8 value" do
      expect(subject.captions_content).to eql(utf8_webvtt_content)
    end
  end

  describe "#valid_webvtt?" do
    subject { described_class.new }
    context "with web vtt content" do
      before { subject.captions_vtt = utf8_webvtt_content }
      it "validates" do
        expect(subject.valid?).to be(true)
      end
    end
    context "with plain text content" do
      before { subject.captions_vtt = 'This is not valid vtt.' }
      it "does not validates" do
        expect(subject.valid?).to be(false)
      end
    end
  end

  describe "validation" do
    context 'encoding' do
      it "validates for valid utf-8 VTT" do
        subject.captions_vtt = "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\nThis is utf-8 🍕!"
        expect(subject.valid?).to be(true)
      end
      it "does not validate for invalid utf-8 VTT" do
        subject.captions_vtt = "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\nThis is áéíóú latin1 encoding!".encode('ISO-8859-1')
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:base]).to include('Captions data must be valid UTF-8')
      end
    end
  end
end
