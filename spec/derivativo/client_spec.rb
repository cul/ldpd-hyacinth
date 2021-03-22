# frozen_string_literal: true

require 'rails_helper'

describe Derivativo::Client do
  let(:valid_client_args) do
    {
      url: 'https://www.derivativo-domain.com:1234',
      api_key: 'abcdefg',
      default_job_options: { access_copy_for_image: { format: 'png' } },
      request_timeout: 123
    }
  end
  let(:instance) { described_class.new(valid_client_args) }
  let(:internal_conn) { instance.instance_variable_get('@conn') }

  let(:job_type) { 'some-type' }
  let(:resource_request_id) { 123 }
  let(:digital_object_uid) { 'abc-123' }
  let(:src_file_location) { 'file://path/to/file' }
  let(:options) { { option1: 'one', option2: 'two' } }
  let(:args) do
    {
      job_type: job_type,
      resource_request_id: resource_request_id,
      digital_object_uid: digital_object_uid,
      src_file_location: src_file_location,
      options: options
    }
  end

  context "new instance" do
    it 'is successfully created when valid arguments are given' do
      expect(instance).to be_a(described_class)
    end
    it 'correctly sets up the internal Faraday connection object' do
      expect(instance.instance_variable_get('@default_job_options')).to eq(valid_client_args[:default_job_options])
      internal_conn.url_prefix.tap do |uri|
        expect(uri.host).to eq('www.derivativo-domain.com')
        expect(uri.port).to eq(1234)
      end
      expect(internal_conn.headers[Faraday::Request::Authorization::KEY]).to eq(%(Token token="#{valid_client_args[:api_key]}"))
    end
  end

  describe '#enqueue_job' do
    before do
      stub_request(:post, "#{valid_client_args[:url]}/api/v1/resource_request_jobs").with(query: hash_including({})).to_return(status: 200)
    end
    it 'performs the expected request' do
      instance.enqueue_job(args)
      expect(
        a_request(:post, "#{valid_client_args[:url]}/api/v1/resource_request_jobs").with(
          query: { resource_request_job: args },
          headers: { Faraday::Request::Authorization::KEY => %(Token token="#{valid_client_args[:api_key]}") }
        )
      ).to have_been_made.once
    end

    context 'after receiving the response' do
      before do
        resp = double
        allow(resp).to receive(:status).and_return(200)
        allow(internal_conn).to receive(:post).and_return(resp)
        expect(instance).to receive(:log_response).with(resp, digital_object_uid, job_type, options)
      end

      it 'logs information about the response' do
        instance.enqueue_job(args)
      end

      it 'returns true if the response status is 200' do
        expect(instance.enqueue_job(args)).to eq(true)
      end
    end

    context 'when a Faraday::ConnectionFailed error is raised' do
      before do
        allow(internal_conn).to receive(:post).and_raise(Faraday::ConnectionFailed, 'Some error message.')
        expect(Rails.logger).to receive(:error).with("Unable to connect to Derivativo, so #{job_type} resource request for #{digital_object_uid} was skipped.")
      end
      it 'logs an error' do
        instance.enqueue_job(args)
      end
    end
  end

  describe '#log_response' do
    let(:response_body) { 'This is the response body.' }
    let(:response) do
      resp = double
      allow(resp).to receive(:status).and_return(status)
      allow(resp).to receive(:body).and_return(response_body)
      resp
    end

    context 'when the response status is 200' do
      let(:status) { 200 }

      it 'logs to the debug log' do
        expect(Rails.logger).to receive(:debug).with(
          "Successfully submitted Derivativo #{job_type} resource request for #{digital_object_uid} with options #{options}."
        )
        instance.send(:log_response, response, digital_object_uid, job_type, options)
      end
    end

    context 'and the response status is 400' do
      let(:status) { 400 }
      it 'logs to the error log' do
        expect(Rails.logger).to receive(:error).with(
          "Received 400 bad request response from Derivativo for #{job_type} resource request for #{digital_object_uid} with options #{options.inspect}. Response body: #{response_body}"
        )
        instance.send(:log_response, response, digital_object_uid, job_type, options)
      end
    end

    context 'and the response status is an unexpected value' do
      let(:status) { 999 }
      it 'logs to the error log' do
        expect(Rails.logger).to receive(:error).with(
          "Received unexpected response for Derivativo resource request of type #{job_type} for #{digital_object_uid} with options #{options.inspect}. Status = #{status}"
        )
        instance.send(:log_response, response, digital_object_uid, job_type, options)
      end
    end
  end
end
