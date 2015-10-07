# We're having issues with PhantomJS timing out.  See: https://github.com/teampoltergeist/poltergeist/issues/375
# Hopefully this will fix the problem.  Solution from: https://gist.github.com/afn/c04ccfe71d648763b306
RSpec.configure do |config|
  config.around(:each, type: :feature) do |ex|
    example = RSpec.current_example
    # Try four times
    3.times do |i|
      example.instance_variable_set('@exception', nil)
      self.instance_variable_set('@__memoized', nil) # clear let variables
      ex.run
      break unless example.exception.is_a?(Capybara::Poltergeist::TimeoutError)
      puts("\nCapybara::Poltergeist::TimeoutError at #{example.location}\n   Restarting phantomjs and retrying...")
      restart_phantomjs
    end
  end
end

def restart_phantomjs
  puts "-> Restarting phantomjs: iterating through capybara sessions..."
  session_pool = Capybara.send('session_pool')
  session_pool.each do |mode,session|
    msg = "  => #{mode} -- "
    driver = session.driver
    if driver.is_a?(Capybara::Poltergeist::Driver)
      msg += "restarting"
      driver.restart
      driver.reset!
    else
      msg += "not poltergeist: #{driver.class}"
    end
    puts msg
  end
end