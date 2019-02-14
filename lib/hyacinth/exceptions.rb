module Hyacinth
  module Exceptions
    class HyacinthError < StandardError; end

    class NotFound < HyacinthError; end

    class DigitalObjectNotFoundError < HyacinthError; end

    class AdapterNotFoundError < StandardError; end
    class UnhandledStorageLocationError < StandardError; end
  end
end
