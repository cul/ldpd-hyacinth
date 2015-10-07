# From: https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
module WaitForAjaxHelper
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script("(typeof jQuery !== \"undefined\") ? jQuery.active : 0").zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjaxHelper, type: :feature
end