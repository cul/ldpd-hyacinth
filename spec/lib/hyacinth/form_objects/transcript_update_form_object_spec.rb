require 'rails_helper'

describe Hyacinth::FormObjects::TranscriptUpdateFormObject do
  let(:utf8_content) { 'Good slice of 🍕!' }
  let(:utf8_bom) { [239, 187, 191].pack('C*') }

  describe "#transcript_content" do
    subject { described_class.new(transcript_text: utf8_content) }

    it "returns the previously set utf-8 value" do
      expect(subject.transcript_content).to eql(utf8_content)
      expect(subject.valid?).to be true
    end
  end

  describe "validation" do
    context 'encoding' do
      subject { described_class.new }
      let(:submitted_content) { utf8_content }

      before { subject.transcript_text = submitted_content }

      context "for valid utf-8 content" do
        it "passes validation" do
          expect(subject.valid?).to be true
        end

        context('with a BOM') do
          let(:submitted_content) { utf8_bom + utf8_content.b }

          it "passes validation" do
            expect(subject.valid?).to be true
          end

          it "uses the stripped utf8" do
            expect(subject.transcript_content).to eql(utf8_content)
          end
        end
      end
      context "for invalid utf-8 content" do
        let(:submitted_content) { "This is áéíóú latin1 encoding!".encode('ISO-8859-1') }

        it "does not passes validation and produces the expected error message" do
          expect(subject.valid?).to be(false)
          expect(subject.errors.messages[:base]).to include('Transcript must be valid UTF-8')
        end
      end
    end
  end
end
