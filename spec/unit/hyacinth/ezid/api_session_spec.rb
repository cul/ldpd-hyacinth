require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Ezid::ApiSession do

  let(:data) {
    {"_status"=>"reserved"}
  }

  let(:expected_anvl) {
    '_status: reserved'
  }

  context "#make_anvl" do
    
    it "creates proper anvl" do
      api_session = Hyacinth::Ezid::ApiSession.new
      actual_anvl = api_session.send(:make_anvl, data)
      expect(actual_anvl).to eq(expected_anvl)
    end
  end
end
