module DigitalObject
  class Asset < DigitalObject::Base

    resource_attribute :master
    resource_attribute :service
    resource_attribute :access

    def initialize
      super
    end
  end
end
