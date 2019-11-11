class Types::TermCategory < Types::BaseEnum
  value "external", "term from an external vocabulary"
  value "temporary", "term with a temporary uri"
  value "local", "term local to our instance"
end
