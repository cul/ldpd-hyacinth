# frozen_string_literal: true
require 'rubocop'
require 'rubocop/cul'

RSpec.describe RuboCop::Cop::CUL::CapybaraScreenshots do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  # TODO: Write test code
  #
  # For example
  it 'registers an offense when using calling `page#save_screenshot`' do
    expect_offense(<<-RUBY.strip_indent)
      page.save_screenshot
      ^^^^^^^^^^^^^^^^^^^^ Remove debugging/instrumentation such as `page#save_screenshot` before committing.
    RUBY
  end

  it 'does not register an offense when using `page#good_method`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      page.good_method
    RUBY
  end
end
