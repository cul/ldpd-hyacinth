# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::BatchImport::IndexPrerequisiteMap do
  let(:csv_file) { File.new(file_fixture('files/batch_import/sample-batch-import.csv')) }

  context ".generate" do
    let(:expected_map) do
      {
        3 => [2],
        4 => [3],
        5 => [4, 6]
      }
    end
    it "generates the expected map" do
      expect(described_class.generate(csv_file)).to eq(expected_map)
    end
  end
end
