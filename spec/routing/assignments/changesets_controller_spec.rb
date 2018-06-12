require "rails_helper"

describe Assignments::ChangesetsController, :type => :routing do
  describe "routing" do

    it "routes to #show" do
      expect(get: "/assignments/foo/changeset").to route_to("assignments/changesets#show", id: 'foo')
    end
  end
end
