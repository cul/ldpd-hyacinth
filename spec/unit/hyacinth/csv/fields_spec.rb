require 'rails_helper'

describe Hyacinth::Csv::Fields do
  let(:field) { described_class.new(header) }

  describe Hyacinth::Csv::Fields::Internal do
    let(:header) { '_publish_target-2.string_key' }
    let(:zero_padded_header) { '_publish_target-02.string_key' }
    let(:pointer) { ['publish_target', 1, 'string_key'] }
    describe '#parse_path' do
      subject { field.parse_path(header) }
      it { is_expected.to eql(pointer) }
    end
    describe '#parse_path with zero-padded header' do
      subject { field.parse_path(zero_padded_header) }
      it { is_expected.to eql(pointer) }
    end
    describe '#to_header' do
      subject { field.to_header }
      it { is_expected.to eql(header) }
    end
    context "a 0-indexed internal field header is supplied" do
      let(:header) { '_publish_target-0.string_key' }
      it { expect { field }.to raise_error('Internal field header names cannot be 0-indexed. Must be 1-indexed.') }
    end

  end
  describe Hyacinth::Csv::Fields::Dynamic do
    let(:header) { 'name-1:name_role-1:name_role_type' }
    let(:zero_padded_header) { 'name-01:name_role-01:name_role_type' }
    let(:pointer) { ['name', 0, 'name_role', 0, 'name_role_type'] }
    describe '#parse_path' do
      subject { field.parse_path(header) }
      it { is_expected.to eql(pointer) }
    end
    describe '#parse_path with zero-padded header' do
      subject { field.parse_path(zero_padded_header) }
      it { is_expected.to eql(pointer) }
    end
    describe '#to_header' do
      subject { field.to_header }
      it { is_expected.to eql(header) }
    end
    context "a 0-indexed internal field header is supplied" do
      let(:header) { 'name-1:name_role-0:name_role_type' }
      it { expect { field }.to raise_error('Dynamic field header names cannot be 0-indexed. Must be 1-indexed.') }
    end
  end
end