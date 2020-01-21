# frozen_string_literal: true

module DigitalObject
  class Asset < DigitalObject::Base
    include DigitalObjectConcerns::Assets::Validations

    PRIMARY_RESOURCE = 'master'

    resource_attribute PRIMARY_RESOURCE.to_sym
    resource_attribute :service
    resource_attribute :access

    metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new

    restriction_attribute :restricted_onsite, Hyacinth::DigitalObject::TypeDef::Boolean.new
    restriction_attribute :restricted_size_image, Hyacinth::DigitalObject::TypeDef::Boolean.new

    def initialize
      super
    end

    # yields to a block with the primary resource name and object
    # returns the resource
    def with_primary_resource(&block)
      block.yield(PRIMARY_RESOURCE, resources[PRIMARY_RESOURCE] ||= Hyacinth::DigitalObject::Resource.new)
      resources[PRIMARY_RESOURCE]
    end
  end
end
