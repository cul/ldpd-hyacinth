require 'rails_helper'

describe Hyacinth::Storage::FileObject do
  let(:path) { '/a/b/object.txt' }
  let(:location_uri) { "file://#{path}" }

  describe "initializer" do
    it "can be instantiated" do
      expect(Hyacinth::Storage::FileObject.new(location_uri)).to be_a(Hyacinth::Storage::FileObject)
    end

    it "successfully parses the given path" do
      expect(Hyacinth::Storage::FileObject.new(location_uri).path).to eq(path)
    end
  end

  it_behaves_like 'storage object'
end
