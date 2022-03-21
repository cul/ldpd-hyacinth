# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::PreserveBehavior do
  include_context 'with stubbed search adapters'
  let(:digital_object) { FactoryBot.create(:digital_object_test_subclass, doi: doi) }
  let(:expected_doi) { '10.abcd/4569' }
  let(:preserve_success) { [true, []] }
  let(:preserve_fail) { [false, ["expected failure"]] }

  describe "#preserve" do
    context 'when an object has an assigned DOI' do
      let(:doi) { expected_doi }
      it "calls preserve without minting a DOI" do
        expect(Hyacinth::Config.preservation_persistence).to receive(:preserve).with(digital_object).and_return(preserve_success)
        expect(Hyacinth::Config.external_identifier_adapter).not_to receive(:mint)
        digital_object.preserve
        expect(digital_object.errors).to be_blank
      end
    end
    context 'when an object does not have an assigned DOI' do
      let(:doi) { nil }

      it "calls preserve after minting a DOI" do
        expect(Hyacinth::Config.preservation_persistence).to receive(:preserve).with(digital_object).and_return(preserve_success)
        expect(Hyacinth::Config.external_identifier_adapter).to receive(:mint).with(digital_object: digital_object).and_return(expected_doi)
        digital_object.preserve
        expect(digital_object.errors).to be_blank
      end
    end
    context 'when preservation fails' do
      let(:doi) { expected_doi }

      it "sets object errors" do
        expect(Hyacinth::Config.preservation_persistence).to receive(:preserve).with(digital_object).and_return(preserve_fail)
        expect(digital_object).not_to receive(:update_preservation_timestamps)
        digital_object.preserve
        expect(digital_object.errors[:preservation]).to be_present
      end
    end
  end
end
