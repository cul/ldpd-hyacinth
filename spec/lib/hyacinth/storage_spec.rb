require 'rails_helper'

describe Hyacinth::Storage do
  describe ".storage_object_for" do
    it "returns the expected object type for a 'file://' uri" do
      expect(Hyacinth::Storage.storage_object_for('file:///path/to/object.txt')).to be_a(Hyacinth::Storage::FileObject)
    end
    it "returns the expected object type for an 's3://' uri" do
      expect(Hyacinth::Storage.storage_object_for('s3://bucket-name/path/to/object.txt')).to be_a(Hyacinth::Storage::S3Object)
    end
  end
end
