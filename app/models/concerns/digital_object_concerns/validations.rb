module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern

  included do
    validates :uid, presence: true, if: :persisted?
    validates :state, inclusion: { in: Hyacinth::DigitalObject::State::VALID_STATES, message: "Invalid state: %{value}" }
  end
end
