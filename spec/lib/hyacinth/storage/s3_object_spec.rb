require 'rails_helper'

describe Hyacinth::Storage::S3Object do
  let(:location_uri) { 's3://path/to/object.txt' }
  describe "instantiation" do
    it "can be instantiated" do
      expect(Hyacinth::Storage::FileObject.new(location_uri)).to be_a(Hyacinth::Storage::FileObject)
    end
  end

  it_behaves_like 'storage object'
end
