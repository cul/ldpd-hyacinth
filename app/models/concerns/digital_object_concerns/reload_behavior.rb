# frozen_string_literal: true

module DigitalObjectConcerns
  module ReloadBehavior
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :reload
    end

    def reload
      # If new record, just call original implementation.  There's no persisted source data for the reload.
      if new_record?
        super
        return
      end

      # If saved record, allow custom reload callbacks to run around original implementation.
      run_callbacks :reload do
        super
      end
    end
  end
end
