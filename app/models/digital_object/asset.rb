module DigitalObject
  class Asset < DigitalObject::Base
    include DigitalObjectConcerns::Assets::Validations

    resource_attribute :master
    resource_attribute :service
    resource_attribute :access

    metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new.public_writer

    def initialize
      super
    end
  end
end
