require "rails_helper"

RSpec.describe XmlDatastreamsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/xml_datastreams").to route_to("xml_datastreams#index")
    end

    it "routes to #new" do
      expect(:get => "/xml_datastreams/new").to route_to("xml_datastreams#new")
    end

    it "routes to #show" do
      expect(:get => "/xml_datastreams/1").to route_to("xml_datastreams#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/xml_datastreams/1/edit").to route_to("xml_datastreams#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/xml_datastreams").to route_to("xml_datastreams#create")
    end

    it "routes to #update" do
      expect(:put => "/xml_datastreams/1").to route_to("xml_datastreams#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/xml_datastreams/1").to route_to("xml_datastreams#destroy", :id => "1")
    end

  end
end
