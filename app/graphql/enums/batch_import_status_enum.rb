# frozen_string_literal: true

class Enums::BatchImportStatusEnum < Types::BaseEnum
  BatchImport::STATUSES.each do |status|
    value str_to_gql_enum(status), "Batch import status of #{status}", value: status
  end
end
