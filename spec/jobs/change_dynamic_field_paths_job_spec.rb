# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangeDynamicFieldPathsJob do
  include_context 'with stubbed search adapters'
  include_examples 'adheres to Hyacinth ActiveJob practices'
end
