module Hyacinth
  module Exceptions
    class HyacinthError < StandardError; end

    class NotFound < HyacinthError; end
    class NotSaved < HyacinthError; end
    class UnableToObtainLockError < HyacinthError; end

    class MissingRequiredOpt < HyacinthError; end

    class UnsupportedType < HyacinthError; end

    class AdapterNotFoundError < StandardError; end
    class UnhandledLocationError < StandardError; end

    class DuplicateTypeError < StandardError; end
  end
end
