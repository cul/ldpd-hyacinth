require 'rails_helper'

describe Hyacinth::FormObjects::TranscriptUpdateFormObject do
  let(:utf8_content) { 'Good slice of 🍕!' }

  describe "#transcript_content" do
    subject { described_class.new }
    before { subject.transcript_text = utf8_content }
    it "returns the previously set utf-8 value" do
      expect(subject.transcript_content).to eql(utf8_content)
    end
  end

  describe "validation" do
    context 'encoding' do
      context "for valid utf-8 content" do
        before { subject.transcript_text = utf8_content }
        it "passes validation" do
          expect(subject.valid?).to be true
        end
      end
      context "for invalid utf-8 content" do
        before { subject.transcript_text = "This is áéíóú latin1 encoding!".encode('ISO-8859-1') }
        it "does not passes validation and produces the expected error message" do
          expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:base]).to include('Transcript must be valid UTF-8')
        end
      end
    end
  end
end
