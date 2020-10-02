# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  value 'CONTAINS', 'contains', value: 'CONTAINS'
  value 'DOES_NOT_CONTAIN', 'does not contain', value: 'DOES_NOT_CONTAIN'
  value 'DOES_NOT_EQUAL', 'does not equal', value: 'DOES_NOT_EQUAL'
  value 'DOES_NOT_EXIST', 'does not exist', value: 'DOES_NOT_EXIST'
  value 'DOES_NOT_START_WITH', 'does not start with', value: 'DOES_NOT_START_WITH'
  value 'EQUALS', 'equals', value: 'EQUALS'
  value 'EXISTS', 'exists', value: 'EXISTS'
  value 'STARTS_WITH', 'starts with', value: 'STARTS_WITH'
end
