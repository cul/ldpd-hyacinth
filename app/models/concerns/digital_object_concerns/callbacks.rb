module DigitalObjectConcerns
  module Callbacks
    extend ActiveSupport::Concern

    included do
      # TODO: Do these things as before_validation callbacks
      # before_validation :register_new_uris_and_values_for_dynamic_field_data!, normalize_controlled_term_fields!

      # # 1) Register any non-existent newly-supplied URIs, adding URIs as needed
      # register_new_uris_and_values_for_dynamic_field_data!(self.dynamic_field_data)
      #
      # # 2) Correct associated URI fields (value, etc.), regardless of what user entered,
      # normalize_controlled_term_fields!(self.dynamic_field_data)
    end
  end
end
