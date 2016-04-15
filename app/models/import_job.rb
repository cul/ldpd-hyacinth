class ImportJob < ActiveRecord::Base

  after_destroy :delete_associated_file_if_exists

  # the name attribute will be the csv filename, and thus may not be unique
  validates :name, presence: true
  has_many :digital_object_imports, dependent: :destroy
  belongs_to :user, required: true


  def success?
    return (DigitalObjectImport.where(import_job_id: self.id, status: [DigitalObjectImport.statuses[:pending], DigitalObjectImport.statuses[:failure]]).count == 0)
  end

  def complete?
    count_pending_digital_object_imports.zero?
  end

  def status_string
    if count_pending_digital_object_imports.nonzero?
      'Incomplete'
    elsif count_failed_digital_object_imports.nonzero?
      'Complete with Failures'
    else
      'Successfully Completed'
    end
  end

  def count_pending_digital_object_imports
    # fcd1, 10/19/15: work on the following, Fred -- does not currently work.
    # self.digital_object_imports.where(digital_object_imports.status == DigitalObjectImport::statuses[:pending]).count

    # fcd1, 10/20/15: may not be the most efficient, but it works
    DigitalObjectImport.where(import_job_id: self.id, status: DigitalObjectImport::statuses[:pending]).count
  end

  def count_successful_digital_object_imports
    # fcd1, 10/20/15: may not be the most efficient, but it works
    DigitalObjectImport.where(import_job_id: self.id, status: DigitalObjectImport::statuses[:success]).count
  end

  def count_failed_digital_object_imports
    # fcd1, 10/20/15: may not be the most efficient, but it works
    DigitalObjectImport.where(import_job_id: self.id, status: DigitalObjectImport::statuses[:failure]).count
  end

  def return_pending_digital_object_imports
    results = Array.new

    # DigitalObjectImport.where(import_job: self).each do |import|
    self.digital_object_imports.each do |import|

      results << import if import.pending?

    end

    results
  end

  def return_successful_digital_object_imports
    results = Array.new

    # DigitalObjectImport.where(import_job: self).each do |import|
    self.digital_object_imports.each do |import|

      results << import if import.success?

    end

    results
  end

  def return_failed_digital_object_imports
    results = Array.new

    # DigitalObjectImport.where(import_job: self).each do |import|
    self.digital_object_imports.each do |import|

      results << import if import.failure?

    end

    results
  end
  
  def delete_associated_file_if_exists
    if self.path_to_csv_file.present? && File.exists?(self.path_to_csv_file)
        FileUtils.rm(self.path_to_csv_file)
    end
  end
  
  def get_csv_row_numbers_for_all_non_successful_digital_object_imports
    return DigitalObjectImport.where(import_job_id: self.id).where.not(status: DigitalObjectImport.statuses[:success]).pluck(:csv_row_number)
  end
end
