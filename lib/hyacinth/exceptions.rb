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

  class InvalidDigitalObjectTypeError < HyacinthError; end
  class MalformedControlledTermFieldValue < HyacinthError; end

  class InvalidCsvHeader < HyacinthError; end
end
