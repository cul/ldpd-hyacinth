# frozen_string_literal: true

module DigitalObjectConcerns
  module IndexBehavior
    extend ActiveSupport::Concern

    # index this digital object for search.
    def index(commit = true)
      Hyacinth::Config.digital_object_search_adapter.index(self, commit: commit)
    end

    # remove this digital object from index for search.
    def deindex(commit = true)
      Hyacinth::Config.digital_object_search_adapter.remove(self, commit: commit)
    end
  end
end
