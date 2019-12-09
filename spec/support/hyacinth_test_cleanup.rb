# frozen_string_literal: true

module HyacinthTestCleanup
  def solr_cleanup
    if Rails.env.test?
      Hyacinth::Config.digital_object_search_adapter.clear_index
      Hyacinth::Config.term_search_adapter.clear
    else
      raise 'This method should only EVER be called in the test environment!'
    end
  end
end
