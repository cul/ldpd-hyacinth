# frozen_string_literal: true

class BatchImport < ApplicationRecord
  PENDING = 'pending'
  IN_PROGRESS = 'in_progress'
  COMPLETED_SUCCESSFULLY = 'completed_successfully'
  COMPLETE_WITH_FAILURES = 'complete_with_failures'
  CANCELLED = 'cancelled'

  STATUSES = [PENDING, IN_PROGRESS, COMPLETED_SUCCESSFULLY, COMPLETE_WITH_FAILURES, CANCELLED].freeze

  enum priority: { low: 0, medium: 1, high: 2 }

  after_destroy :delete_associated_file

  has_many :digital_object_imports, dependent: :destroy
  belongs_to :user

  validates :priority, presence: true

  def delete_associated_file
    Hyacinth::Config.batch_import_storage.delete(file_location) if file_location.present?
  end

  def status
    return CANCELLED if cancelled

    total_imports = import_status_count.values.sum
    if import_count('in_progress').positive?
      IN_PROGRESS
    elsif import_count('pending') == total_imports
      PENDING
    elsif import_count('success') == total_imports
      COMPLETED_SUCCESSFULLY
    else
      COMPLETE_WITH_FAILURES
    end
  end

  # This method queries for the count of each status once and caches it. For subsequent requests the same
  # count will be used, it will not be recalculated.
  def import_status_count
    @import_status_count ||= digital_object_imports.group(:status).count
  end

  def import_count(status)
    import_status_count[status] || 0
  end
end
