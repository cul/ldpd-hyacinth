# frozen_string_literal: true

class Enums::ExportJobStatusEnum < Types::BaseEnum
  ExportJob.statuses.each do |value_string, _value_number|
    value value_string, value_string
  end
end
