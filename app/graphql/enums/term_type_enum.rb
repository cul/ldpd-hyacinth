# frozen_string_literal: true

class Enums::TermTypeEnum < Types::BaseEnum
  value "EXTERNAL", "term from an external vocabulary", value: 'external'
  value "TEMPORARY", "term with a temporary uri", value: 'temporary'
  value "LOCAL", "term local to our instance", value: 'local'
end
