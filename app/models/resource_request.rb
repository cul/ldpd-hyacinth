# frozen_string_literal: true

class ResourceRequest < ApplicationRecord
  attr_accessor :create_callback

  enum status: { pending: 0, in_progress: 1, success: 2, failure: 3, cancelled: 4 }
  enum job_type: {
    access_for_image: 0,
    access_for_video: 1,
    access_for_audio: 2,
    access_for_pdf: 3,
    access_for_text_or_office_document: 4,
    poster_for_video: 5,
    poster_for_pdf: 6,
    fulltext: 7,
    featured_thumbnail_region: 8,
    iiif_registration: 9,
    iiif_deregistration: 10
  }

  validates :digital_object_uid, presence: true
  validates :job_type, presence: true
  validates :status, presence: true
  validates :src_file_location, presence: true

  serialize :options, Hash
  serialize :processing_errors, Array

  # Do not run this in after_create or you'll get sqlite database lock issues when ActiveJob jobs
  # are set to run inline (in development or test environments). The problem is that logic inside of
  # enqueue_derivativo_job ends up making requests to Derivativo which makes requests back to
  # Hyacinth and those requests fail when there's an existing lock on the squlite database.
  # See: https://flexport.engineering/how-to-safely-use-activerecords-after-save-efde2b52baa3
  after_commit :run_create_callback, on: :create

  def run_create_callback
    create_callback&.call(self)
  end
end
