# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::BatchImport::IndexPrerequisiteMap do
  let(:csv_file) { File.new(file_fixture('files/batch_import/sample-batch-import.csv')) }

  let(:generated_identifier_maps) { described_class.generate_csv_identifier_maps(csv_file) }
  let(:generated_identifiers_to_row_numbers) { generated_identifier_maps[0] }
  let(:generated_row_numbers_to_parent_identifiers) { generated_identifier_maps[1] }
  let(:generated_row_numbers_to_parent_row_numbers_map) do
    described_class.generate_row_numbers_to_parent_row_numbers_map(
      generated_identifiers_to_row_numbers, generated_row_numbers_to_parent_identifiers
    )
  end
  let(:generated_processing_order_map) do
    described_class.generate_processing_order_map(
      generated_row_numbers_to_parent_row_numbers_map
    )
  end
  let(:generated_index_prerequisite_map) do
    described_class.generate_index_prerequisite_map(
      generated_processing_order_map
    )
  end

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

    context "checks the generated map for circular depenencies" do
      before do
        hsh = object_double(Hash)
        allow(described_class).to receive(:generate_index_prerequisite_map).and_return(hsh)
        expect(described_class).to receive(:raise_error_if_circular_dependency_found!).with(hsh)
      end
      it do
        described_class.generate(csv_file)
      end
    end
  end

  context '.generate_csv_identifier_maps' do
    let(:expected_identifiers_to_row_numbers) do
      {
        "2f4e2917-26f5-4d8f-968c-a4015b10e50f" => 2,
        "item1" => 2,
        "asset1" => 3,
        "asset2" => 4,
        "asset3" => 5,
        "item2" => 6
      }
    end
    let(:expected_row_numbers_to_parent_identifiers) do
      {
        3 => ["2f4e2917-26f5-4d8f-968c-a4015b10e50f"],
        4 => ["item1"],
        5 => ["item1", "item2"]
      }
    end
    it 'generates the expected maps' do
      expect(described_class.generate_csv_identifier_maps(csv_file)).to eq(generated_identifier_maps)
    end
  end

  context '.generate_row_numbers_to_parent_row_numbers_map' do
    let(:expected_row_numbers_to_parent_row_numbers) do
      {
        3 => [2],
        4 => [2],
        5 => [2, 6]
      }
    end
    it 'generates the expected map' do
      expect(generated_row_numbers_to_parent_row_numbers_map).to eq(expected_row_numbers_to_parent_row_numbers)
    end
  end

  context '.generate_processing_order_map' do
    let(:expected_processing_order_map) do
      {
        2 => [3, 4, 5],
        6 => [5]
      }
    end
    it 'generates the expected map' do
      expect(generated_processing_order_map).to eq(expected_processing_order_map)
    end
  end

  context '.generate_index_prerequisite_map' do
    let(:expected_index_prerequisite_map) do
      {
        3 => [2],
        4 => [3],
        5 => [4, 6]
      }
    end
    it 'generates the expected map' do
      expect(generated_index_prerequisite_map).to eq(expected_index_prerequisite_map)
    end
  end

  context '.raise_error_if_circular_dependency_found!' do
    let(:circular_dependency_map) do
      {
        20 => [19, 15],
        15 => [20]
      }
    end
    let(:non_circular_dependency_map) do
      {
        3 => [2, 1],
        4 => [3],
        5 => [4, 6]
      }
    end
    it "raises an error when a circular dependency map is given" do
      expect {
        described_class.raise_error_if_circular_dependency_found!(circular_dependency_map)
      }.to raise_error(Hyacinth::Exceptions::BatchImportError)
    end
    it "does not raise an error when a non-circular dependency map is given" do
      expect {
        described_class.raise_error_if_circular_dependency_found!(non_circular_dependency_map)
      }.not_to raise_error
    end
  end

  context '.recurse_hierarchy' do
    let(:index_prerequisite_map) do
      {
        3 => [2, 1],
        4 => [3],
        5 => [4, 6]
      }
    end
    let(:row_numbers) { [4, 5] }
    let(:expected_successive_yield_args) { [4, 3, 2, 1, 5, 4, 3, 2, 1, 6] }
    it "yields the expected values in the expected order" do
      expect { |b|
        described_class.recurse_hierarchy(index_prerequisite_map, row_numbers, &b)
      }.to yield_successive_args(*expected_successive_yield_args)
    end
  end
end
