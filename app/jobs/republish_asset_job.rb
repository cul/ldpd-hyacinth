class RepublishAssetJob < ActiveJob::Base
  queue_as Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_LOW

  def perform(digital_object_pid)
    obj = DigitalObject::Base.find(digital_object_pid)
    # return unless ths is a published asset
    return unless obj.is_a?(DigitalObject::Asset) && obj.pid.present? && obj.publish_target_pids.present?

    obj.publish(false)
  end
end
