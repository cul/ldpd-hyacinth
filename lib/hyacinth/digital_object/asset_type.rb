module Hyacinth
  module DigitalObject
    module AssetType
      # https://github.com/duraspace/pcdm/blob/master/pcdm-ext/file-format-types.rdf
      AUDIO = "Audio".freeze
      EMAIL = "Email".freeze
      HTML = "HTML".freeze
      IMAGE = "Image".freeze
      PAGE_DESCRIPTION = "PageDescription".freeze
      PRESENTATION = "Presentation".freeze
      SOFTWARE = "Software".freeze
      SPREADSHEET = "Spreadsheet".freeze
      STRUCTURED_TEXT = "StructuredText".freeze
      TEXT = "Text".freeze
      UNKNOWN = "Unknown".freeze
      UNSTRUCTURED_TEXT = "UnstructuredText".freeze
      VIDEO = "Video".freeze

      VALID_TYPES = [
        AUDIO, EMAIL, HTML, IMAGE, PAGE_DESCRIPTION, PRESENTATION, SOFTWARE,
        SPREADSHEET, STRUCTURED_TEXT, TEXT, UNKNOWN, UNSTRUCTURED_TEXT, VIDEO
      ].freeze
    end
  end
end
