# frozen_string_literal: true

module Hyacinth
  module Exceptions
    class HyacinthError < StandardError; end

    class DeletionError < HyacinthError; end
    class PurgeError < HyacinthError; end
    class NotFound < HyacinthError; end
    class NotSaved < HyacinthError; end
    class LockError < HyacinthError; end

    class Deserialization < HyacinthError; end

    class Rollback < HyacinthError; end
    class UnexpectedErrors < HyacinthError; end
    class MissingErrors < HyacinthError; end

    class AlreadySet < HyacinthError; end

    class MissingRequiredOpt < HyacinthError; end

    class UnsupportedType < HyacinthError; end

    class ChecksumMismatchError < HyacinthError; end
    class InvalidChecksumFormatError < HyacinthError; end

    class AdapterNotFoundError < HyacinthError; end
    class UnhandledLocationError < HyacinthError; end

    class DuplicateTypeError < HyacinthError; end

    class ResourceImportError < HyacinthError; end
    class BatchImportError < HyacinthError; end

    class VocabularyLocked < HyacinthError; end
  end
end
