module DigitalObject
  # Minimal class used for testing, since Base cannot be instantiated.
  # Only intended to be available in the test environment.
  class Test < DigitalObject::Base
    def initialize
      super
    end
  end
end
