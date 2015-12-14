require "rails_helper"

RSpec.describe CsvExportsController, :type => :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/csv_exports").to route_to("csv_exports#index")
    end

    it "disables #new" do
      expect(:get => "/csv_exports/new").not_to route_to("csv_exports#new")
    end

    it "routes to #show" do
      expect(:get => "/csv_exports/1").to route_to("csv_exports#show", :id => "1")
    end

    it "disables #edit" do
      expect(:get => "/csv_exports/1/edit").not_to route_to("csv_exports#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/csv_exports").to route_to("csv_exports#create")
    end

    it "disables #update" do
      expect(:put => "/csv_exports/1").not_to route_to("csv_exports#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/csv_exports/1").to route_to("csv_exports#destroy", :id => "1")
    end
  end
end
