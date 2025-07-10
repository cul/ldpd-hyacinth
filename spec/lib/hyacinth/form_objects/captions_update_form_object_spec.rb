require 'rails_helper'

describe Hyacinth::FormObjects::CaptionsUpdateFormObject do
  let(:utf8_webvtt_content) { "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\nGood slice of 🍕!" }
  let(:utf8_text_content) { 'This is not valid vtt.' }
  let(:utf8_bom) { [239, 187, 191].pack('C*') }
  let(:latin1_webtt_content) { "WEBVTT\n\n00:00:00.000 --> 00:00:25.000\nThis is áéíóú latin1 encoding!".encode('ISO-8859-1') }

  subject { described_class.new(captions_vtt: utf8_webvtt_content) }


  describe '#captions_content' do
    it 'returns the previously set utf-8 value of the captions_vtt attribute' do
      expect(subject.valid?).to be(true)
      expect(subject.captions_content).to eql(utf8_webvtt_content)
    end
    context 'existing content is blank' do
      subject { described_class.new }

      it 'returns the blank value of the captions_vtt attribute' do
        expect(subject.valid?).to be(false)
        expect(subject.captions_content).to be_blank
      end
    end
  end

  describe '#valid_webvtt?' do
    subject { described_class.new }

    before { subject.captions_vtt = submitted_content }

    context "with web vtt content" do
      let(:submitted_content) { utf8_webvtt_content }
      it "validates" do
        expect(subject.valid?).to be(true)
      end
    end

    context 'with plain text content' do
      let(:submitted_content) { utf8_text_content }
      it "does not validates" do
        expect(subject.valid?).to be(false)
      end
    end
  end

  describe '#validate_encoding' do
    before { subject.captions_vtt = submitted_content }

    context 'UTF8 encoding' do
      let(:submitted_content) { utf8_webvtt_content }

      it 'validates for valid utf-8 VTT' do
        expect(subject.valid?).to be(true)
        expect(subject.captions_content).to eql(utf8_webvtt_content)
      end

      context 'with a BOM' do
        let(:submitted_content) { utf8_bom + utf8_webvtt_content.b }

        it "validates for valid utf-8 VTT with a BOM" do
          expect(subject.valid?).to be(true)
          expect(subject.captions_content).to eql(utf8_webvtt_content)
        end
      end
    end

    context 'non-UTF8 encoding' do
      let(:submitted_content) { latin1_webtt_content }

      it "does not validate for invalid utf-8 VTT" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:base]).to include('Captions data must be valid UTF-8')
      end
    end
  end
end
