require 'rails_helper'

describe Hyacinth::Storage do
  describe ".for" do
    it "returns the expected object type" do
      expect(Hyacinth::Storage.for('file:///path/to/file.txt')).to be_a(Hyacinth::Storage::FileObject)
      expect(Hyacinth::Storage.for('s3://bucket-name/path/to/object.txt')).to be_a(Hyacinth::Storage::S3Object)
    end
  end
end
