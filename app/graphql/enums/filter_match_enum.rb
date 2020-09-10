# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  value 'ABSENT', 'absent (negated present)', value: 'absent'
  value 'CONTAINS', 'contains', value: 'contains'
  value 'MATCHES', 'matches', value: 'matches'
  value 'OMITS', 'omits (negated contains)', value: 'omits'
  value 'PRESENT', 'present', value: 'present'
  value 'VARIES', 'varies (negated matches)', value: 'varies'
end
