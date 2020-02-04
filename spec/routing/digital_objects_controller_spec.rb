require "rails_helper"

RSpec.describe DigitalObjectsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/digital_objects").to route_to("digital_objects#index")
    end

    it "routes to #new" do
      expect(:get => "/digital_objects/new").to route_to("digital_objects#new")
    end

    it "routes to #show" do
      expect(:get => "/digital_objects/1").to route_to("digital_objects#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/digital_objects/1/edit").to route_to("digital_objects#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/digital_objects").to route_to("digital_objects#create")
    end

    it "routes to #update" do
      expect(:put => "/digital_objects/1").to route_to("digital_objects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/digital_objects/1").to route_to("digital_objects#destroy", :id => "1")
    end

    it "routes to #download_captions" do
      expect(:get => "/digital_objects/1/captions").to route_to("digital_objects#download_captions", :id => "1")
    end

    it "routes to #update_captions" do
      expect(:put => "/digital_objects/1/captions").to route_to("digital_objects#update_captions", :id => "1")
    end

    it "routes to #download_transcript" do
      expect(:get => "/digital_objects/1/transcript").to route_to("digital_objects#download_transcript", :id => "1")
    end

    it "routes to #update_transcript" do
      expect(:put => "/digital_objects/1/transcript").to route_to("digital_objects#update_transcript", :id => "1")
    end

    it "routes to #download_synchronized_transcript" do
      expect(:get => "/digital_objects/1/synchronized_transcript").to route_to("digital_objects#download_synchronized_transcript", :id => "1")
    end

    it "routes to #update_synchronized_transcript" do
      expect(:put => "/digital_objects/1/synchronized_transcript").to route_to("digital_objects#update_synchronized_transcript", :id => "1")
    end

  end
end
