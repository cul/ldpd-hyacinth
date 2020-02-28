# frozen_string_literal: true

class Enums::BatchImportStatusEnum < Types::BaseEnum
  BatchImport::STATUSES.each do |status|
    value status, status
  end
end
