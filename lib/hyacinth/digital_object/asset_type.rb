# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module AssetType
      # https://github.com/duraspace/pcdm/blob/master/pcdm-ext/file-format-types.rdf
      AUDIO = "Audio"
      EMAIL = "Email"
      HTML = "HTML"
      IMAGE = "Image"
      PAGE_DESCRIPTION = "PageDescription"
      PRESENTATION = "Presentation"
      SOFTWARE = "Software"
      SPREADSHEET = "Spreadsheet"
      STRUCTURED_TEXT = "StructuredText"
      TEXT = "Text"
      UNKNOWN = "Unknown"
      UNSTRUCTURED_TEXT = "UnstructuredText"
      VIDEO = "Video"

      VALID_TYPES = [
        AUDIO, EMAIL, HTML, IMAGE, PAGE_DESCRIPTION, PRESENTATION, SOFTWARE,
        SPREADSHEET, STRUCTURED_TEXT, TEXT, UNKNOWN, UNSTRUCTURED_TEXT, VIDEO
      ].freeze
    end
  end
end
