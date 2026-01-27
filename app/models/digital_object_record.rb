class DigitalObjectRecord < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  after_initialize :assign_uuid!, if: :new_record?

  validates :uuid, presence: true

  private

    def assign_uuid!
      self.uuid = SecureRandom.uuid
    end
end
