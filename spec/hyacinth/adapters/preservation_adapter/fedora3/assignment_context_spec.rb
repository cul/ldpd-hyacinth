# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::PreservationAdapter::Fedora3::AssignmentContext do
  let(:client) { test_class.new }
  let(:adapter) { instance_double(Hyacinth::Adapters::PreservationAdapter::Fedora3) }
  let(:test_class) do
    Class.new do
      include Hyacinth::Adapters::PreservationAdapter::Fedora3::AssignmentContext::Client
    end
  end

  let(:test_property_class) do
    Class.new do
      def self.from(adapter, src)
        new(adapter, src)
      end

      def initialize(_adapter, src)
        @src = src
      end

      def to(target)
        target[:message] = @src[:message]
      end
    end
  end

  let(:expected_message) { 'source message' }
  let(:test_source) { { message:  expected_message } }
  let(:test_target) { { message:  'decoy message' } }

  it "works going from to" do
    client.assign(test_property_class).from(adapter, test_source).to(test_target)
    expect(test_target[:message]).to eql(expected_message)
  end

  it "works going to from" do
    client.assign(test_property_class).to(test_target).from(adapter, test_source)
    expect(test_target[:message]).to eql(expected_message)
  end
end
