# frozen_string_literal: true

require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::EzidSession do
  let(:data) do
    { "_status" => "reserved" }
  end

  let(:expected_anvl) { '_status: reserved' }

  context "#make_anvl" do
    let(:test_user) { DATACITE[:test_user] }
    let(:test_password) { DATACITE[:test_password] }
    it "creates proper anvl" do
      api_session = described_class.new(test_user, test_password)
      actual_anvl = api_session.send(:make_anvl, data)
      expect(actual_anvl).to eq(expected_anvl)
    end
  end
end
