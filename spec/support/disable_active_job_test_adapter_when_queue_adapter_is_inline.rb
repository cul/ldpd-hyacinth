# In Rails 6, Rails overrides the ActiveJob queue adapter to :test for certain types of tests,
# even if you've specifically set it to :inline.  This means that in tests, calls to
# SomeJobClass.perform_later will NOT run synchronously (as you'd expect), but instead the
# perform_later operation will be absorbed by the test adapter and the job will not execute.
# This is not obvious, and printing out the value of Rails.application.config.active_job.queue_adapter
# will actually still show :inline, even though Rails is acting like the value was set to :test.
# This is not desirable in Hyacinth, so the configuration in this file undoes that and enables
# jobs to run in a test environment when the queue_adapter is set to :inline for the test environment.
# For additional context, see: https://github.com/rails/rails/issues/37270

RSpec.configure do |config|
  config.before(:each) do |example|
    if Rails.application.config.active_job.queue_adapter == :inline
      (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
    end
  end
end
