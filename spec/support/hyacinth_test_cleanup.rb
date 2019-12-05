# frozen_string_literal: true

module HyacinthTestCleanup
  def clear_search_index
    if Rails.env.test?
      Hyacinth.config.search_adapter.clear_index
      Hyacinth.config.term_search_adapter.clear
    else
      raise 'This method should only EVER be called in the test environment!'
    end
  end
end
