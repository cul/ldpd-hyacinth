# frozen_string_literal: true

class Enums::BatchImportStatusEnum < Types::BaseEnum
  BatchImport::STATUSES.each do |status|
    value status.upcase.tr(' ', '_'), "Batch import status of #{status}", value: status
  end
end
