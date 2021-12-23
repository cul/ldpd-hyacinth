# frozen_string_literal: true

module Hyacinth
  module Exceptions
    class HyacinthError < StandardError; end

    class DeletionError < HyacinthError; end
    class NotFound < HyacinthError; end
    class NotSaved < HyacinthError; end
    class LockError < HyacinthError; end

    class Deserialization < HyacinthError; end

    class InvalidLocationUri < HyacinthError; end

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

    class BatchImportError < HyacinthError; end

    class VocabularyLocked < HyacinthError; end

    class InvalidPersistConditions < HyacinthError; end
    class PublishFailure < HyacinthError; end
    class UnpublishFailure < HyacinthError; end
  end
end
