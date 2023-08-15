class RequestDerivativesJob < ActiveJob::Base
  queue_as Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_LOW

  def perform(digital_object_pid)
    obj = DigitalObject::Base.find(digital_object_pid)
    # return unless ths is an asset
    return unless obj.is_a?(DigitalObject::Asset)

    # TODO: Make request to Derivativo
  end
end
