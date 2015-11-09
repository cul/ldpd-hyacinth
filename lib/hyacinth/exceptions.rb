module Hyacinth::Exceptions
  class DigitalObjectNotFoundError < StandardError; end
  class ProjectNotFoundError < StandardError; end
  class PublishTargetNotFoundError < StandardError; end
  class BuilderPathNotFoundError < StandardError; end
  class InvalidDigitalObjectTypeError < StandardError; end
end