# frozen_string_literal: true

class BatchImport < ApplicationRecord
  enum priority: { low: 0, medium: 1, high: 2 }
  enum status: { pending: 0, in_progress: 1, completed_successfully: 2, complete_with_failures: 3, cancelled: 4 }

  after_destroy :delete_associated_file

  has_many :digital_object_imports, dependent: :destroy
  belongs_to :user

  validates :priority, :status, presence: true

  def delete_associated_file
    Hyacinth::Config.batch_import_storage.delete(file_location) if file_location.present?
  end

  def import_count(status)
    @import_status_count ||= digital_object_imports.group(:status).count
    @import_status_count[status] || 0
  end
end
