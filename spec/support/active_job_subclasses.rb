# frozen_string_literal: true

shared_examples 'adheres to Hyacinth ActiveJob practices' do
  it "is an ActiveJob::Base" do
    expect(described_class.new).to be_kind_of ActiveJob::Base
  end
  describe '.queue_as' do
    it "configures a non-default queue designation" do
      # the default behavior returns a Proc; assigned queues result in a String
      expect(described_class.queue_name).to be_a String
      expect(described_class.queue_name).not_to eql("#{Rails.application.config.active_job.queue_name_prefix}.default")
    end
  end
end
