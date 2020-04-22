# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectImport, type: :model do
  describe '#new' do
    subject(:digital_object_import) { FactoryBot.create(:digital_object_import) }

    it { is_expected.to be_a DigitalObjectImport }
    its(:batch_import) { is_expected.to be_a BatchImport }
    its(:status)       { is_expected.to eql 'in_progress' }
    its(:index)        { is_expected.to be 34 }
    its(:digital_object_data) do
      is_expected.to eql('{"descriptive_metadata":{"abstract":[{"abstract_value":"some abstract"}]}}')
    end
  end
end
