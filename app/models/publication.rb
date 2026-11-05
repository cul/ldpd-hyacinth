class Publication < ApplicationRecord
  belongs_to :digital_object_record
  belongs_to :publish_target

  enum :status, {
    publish_pending: 'publish_pending',
    published: 'published',
    unpublish_pending: 'unpublish_pending',
    unpublished: 'unpublished'
  }
end
