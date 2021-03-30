# frozen_string_literal: true

module DigitalObjectConcerns
  module IndexBehavior
    extend ActiveSupport::Concern

    # index this digital object for search.
    def index
      Hyacinth::Config.digital_object_search_adapter.index(self)
    end

    # remove this digital object from index for search.
    def deindex
      Hyacinth::Config.digital_object_search_adapter.remove(self)
    end

    def index_test
      Hyacinth::Config.digital_object_search_adapter.index_test(self)
    end
  end
end
