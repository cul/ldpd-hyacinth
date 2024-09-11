require 'rails_helper'

describe Hyacinth::Storage::AbstractObject do
  describe "instantiation" do
    it "cannot be instantiated because it is meant to be an abstract class" do
      expect { Hyacinth::Storage::AbstractObject.new('file:///a/b/c.txt') }.to raise_error(NotImplementedError)
    end
  end
end
