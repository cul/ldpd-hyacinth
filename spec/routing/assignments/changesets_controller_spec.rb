require "rails_helper"

describe Assignments::ChangesetsController, :type => :routing do
  describe "routing" do

    it "routes to #update" do
      expect(put: "/assignments/foo/changeset").to route_to("assignments/changesets#update", id: 'foo')
    end
  end
end
