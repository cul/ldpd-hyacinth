# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceRequests::AbstractJob do
  let(:digital_object) do
    dbl = instance_double(DigitalObject::Item)
    allow(dbl).to receive(:uid).and_return('abcdefg')
    dbl
  end

  describe '.perform_later_if_eligible' do
    context 'for an eligible object' do
      before { allow(described_class).to receive(:eligible_object?).and_return(true) }
      it 'calls perform_later' do
        expect(described_class).to receive(:perform_later).with(digital_object.uid)
        described_class.perform_later_if_eligible(digital_object)
      end
    end

    context 'for an ineligible object' do
      before { allow(described_class).to receive(:eligible_object?).and_return(false) }
      it 'does not call perform_later' do
        expect(described_class).not_to receive(:perform_later)
        described_class.perform_later_if_eligible(digital_object)
      end
    end
  end

  describe '.eligible_object?' do
    it 'raises a NotImplemented error because it should be overridden by a subclass' do
      expect { described_class.eligible_object?(digital_object) }.to raise_error(NotImplementedError)
    end
  end
end
