module Hyacinth::Exceptions
  class HyacinthError < StandardError; end

  class NotFoundError < HyacinthError; end
  class ZeroByteFileError < HyacinthError; end
  class AssociatedFedoraObjectNotFoundError < NotFoundError; end
  class DigitalObjectNotFoundError < NotFoundError; end
  class ParentDigitalObjectNotFoundError < NotFoundError; end
  class ProjectNotFoundError < NotFoundError; end
  class PublishTargetNotFoundError < NotFoundError; end
  class BuilderPathNotFoundError < NotFoundError; end
  class InvalidUtf8DetectedError < NotFoundError; end

  class InvalidDigitalObjectTypeError < HyacinthError; end
  class MalformedControlledTermFieldValue < HyacinthError; end

  class InvalidCsvHeader < HyacinthError; end

  class FileOverwriteError < HyacinthError; end
  class FileImportError < HyacinthError; end

  class DataciteConnectionError < HyacinthError; end
  class DataciteErrorResponse < HyacinthError; end
  class DoiExists < HyacinthError; end
  class MissingDoi < HyacinthError; end
end
