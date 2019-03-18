module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern

  included do
    validates :uid, presence: true, if: :persisted?
    validates :state, inclusion: { in: Hyacinth::DigitalObject::State::VALID_STATES, message: "Invalid state: %{value}" }

    # Validate URI fields and raise exception if any of them are malformed
    # raise_exception_if_malformed_controlled_field_data!
  end
end
