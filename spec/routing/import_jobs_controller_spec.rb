require "rails_helper"

RSpec.describe ImportJobsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/import_jobs").to route_to("import_jobs#index")
    end

    it "routes to #new" do
      expect(:get => "/import_jobs/new").to route_to("import_jobs#new")
    end

    it "routes to #show" do
      expect(:get => "/import_jobs/1").to route_to("import_jobs#show", :id => "1")
    end

    it "disables #edit" do
      expect(:get => "/import_jobs/1/edit").not_to route_to("import_jobs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/import_jobs").to route_to("import_jobs#create")
    end

    it "disables #update" do
      expect(:put => "/import_jobs/1").not_to route_to("import_jobs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/import_jobs/1").to route_to("import_jobs#destroy", :id => "1")
    end

  end
end
