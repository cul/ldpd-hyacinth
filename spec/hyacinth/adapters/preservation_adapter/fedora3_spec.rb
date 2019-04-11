require 'rails_helper'

describe Hyacinth::Adapters::PreservationAdapter::Fedora3 do
  let(:connection) { Rubydora::Repository.new({}, connection_api) }
  let(:connection_api) do
    a = instance_double("Rubydora::Fc3Service")
    allow(a).to receive(:repository_profile)
    a
  end
  let(:resource) { instance_double("RestClient::Resource") }
  let(:subresource) { instance_double("RestClient::Resource") }
  let(:object_pid) { "test:1" }
  let(:location_uri) { "fedora://" + object_pid }
  let(:pid_generator) { instance_double(PidGenerator) }
  let(:adapter_args) { { url: 'foo', password: 'foo', user: 'foo', pid_generator: pid_generator } }
  let(:adapter) do
    a = described_class.new(adapter_args)
    a.instance_variable_set("@connection", connection)
    a
  end
  let(:request) do
    a = instance_double("RestClient::Request")
    allow(a).to receive(:args).and_return({})
    a
  end

  before do
    allow(connection).to receive(:client).and_return(resource)
    allow(request).to receive(:redirection_history).and_return []
  end

  describe "#exists?" do
    let(:object_url) { "/objects/#{object_pid}/object.xml" }
    let(:response_headers) { {} }
    context "an object exists" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPOK")
        allow(a).to receive(:code).and_return 200
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("OK", net_http_response, request) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_return(response)
        expect(net_http_response).to receive(:code).and_return(200)
      end

      it { expect(adapter.exists?(location_uri)).to be true }
    end

    context "an object does not exist" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPNotFound")
        allow(a).to receive(:code).and_return 404
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("Not Found", net_http_response, request) }
      let(:exception_with_response) { RestClient::ExceptionWithResponse.new(response) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_raise(exception_with_response)
      end

      it { expect(adapter.exists?(location_uri)).to be false }
    end

    context "the repository raises a runtime error" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPServerError")
        allow(a).to receive(:code).and_return 500
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("A runtime error", net_http_response, request) }
      let(:exception_with_response) { RestClient::RequestFailed.new(response) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_raise(exception_with_response)
        expect(net_http_response).to receive(:code).and_return(500)
      end

      it "passes along the error" do
        expect { adapter.exists?(location_uri) }.to raise_exception(RestClient::RequestFailed)
      end
    end
  end
  describe "#generate_new_location_uri" do
    subject { adapter.generate_new_location_uri }
    before do
      allow(pid_generator).to receive(:next_pid).and_return(*([1, 2, 3].map { |x| "test:#{x}" }))
      allow(adapter).to receive(:exists?).and_return(true, true, false)
    end
    it "returns the first new location URI" do
      is_expected.to eql("fedora3://test:3")
    end
  end
end
