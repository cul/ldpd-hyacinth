# frozen_string_literal: true

class Enums::TermTypeEnum < Types::BaseEnum
  value "EXTERNAL", "term from an external vocabulary"
  value "TEMPORARY", "term with a temporary uri"
  value "LOCAL", "term local to our instance"
end
