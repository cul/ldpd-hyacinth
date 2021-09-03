# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceRequest, type: :model do
  let(:instance) { FactoryBot.build(:resource_request) }

  describe '#new' do
    it 'creates a new instance of the expected type' do
      expect(instance).to be_a(ResourceRequest)
    end

    it "has a status that defaults to 'pending'" do
      expect(instance.status).to eq('pending')
    end
  end

  describe "saving" do
    context 'valid object' do
      it 'saves' do
        expect(instance.save).to eq(true)
      end
    end

    context 'when a required field is missing' do
      ['digital_object_uid', 'job_type', 'status', 'src_file_location'].each do |required_field|
        context "missing #{required_field}" do
          before { instance.send("#{required_field}=", nil) }
          it 'does not save' do
            expect(instance.save).to eq(false)
          end

          it 'returns correct error' do
            instance.save
            expect(instance.errors.full_messages).to include "#{required_field.humanize} can't be blank"
          end
        end
      end
    end
  end

  describe '.run_create_callback' do
    let(:expected_resource_request_id) { 1 }
    it 'fires after instance create' do
      expect(instance).to receive(:run_create_callback)
      instance.save
    end

    context 'enqueues a job with the expected parameters' do
      let(:callback) { instance_double(Proc) }
      let(:instance) { FactoryBot.build(:resource_request, create_callback: callback) }
      before do
        expect(callback).to receive(:call).with(an_instance_of(ResourceRequest))
      end
      it 'and the created instance has the same id as the resource_request_id param in the enqueued job' do
        instance.save
        expect(instance.id).to eq(expected_resource_request_id)
      end
    end
  end
end
