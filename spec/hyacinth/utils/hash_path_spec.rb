require 'rails_helper'

RSpec.describe Hyacinth::Utils::HashPath do
  context ".hash_path" do
    let(:base_path) { '/the/base/path' }
    let(:identifier) { 'abc:123456' }
    let(:expected_path) { '/the/base/path/71/f7/9d/dc/5d/ba/71f79ddc5dba7d98fd09ade46f1d21c8c1ea9965b2acc9b4ccaf41fba8dd808e' }
    it "generates the expected path" do
      expect(described_class.hash_path(base_path, identifier)).to eq(expected_path)
    end
  end
end
