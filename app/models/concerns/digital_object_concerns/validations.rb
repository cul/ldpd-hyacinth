module DigitalObjectConcerns::Validations
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  # validates :state, inclusion: {
  #   in: Hyacinth::DigitalObject::State::VALID_STATES
  #   #, message: "Invalid state: %{value}"
  # }

  def valid?
    self.errors.add(:state,  "Invalid state: #{self.state}") unless Hyacinth::DigitalObject::State::VALID_STATES.include?(self.state)

    # TODO: Do the rest of the validations

    self.errors.empty?
  end
end
