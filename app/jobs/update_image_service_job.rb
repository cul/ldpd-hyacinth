class UpdateImageServiceJob < ActiveJob::Base
  queue_as Hyacinth::Queue::IMAGE_SERVICE

  def perform(digital_object_pid)
    obj = DigitalObject::Base.find(digital_object_pid)
    # return unless ths is an asset
    return unless obj.is_a?(DigitalObject::Asset)

    # TODO: Make request to Triclops
  end
end
