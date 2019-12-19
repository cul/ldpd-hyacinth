# frozen_string_literal: true

module DigitalObject
  class Asset < DigitalObject::Base
    include DigitalObjectConcerns::Assets::Validations

    resource_attribute :master
    resource_attribute :service
    resource_attribute :access

    metadata_attribute :asset_type, Hyacinth::DigitalObject::TypeDef::String.new

    restriction_attribute :restricted_onsite, Hyacinth::DigitalObject::TypeDef::Boolean.new
    restriction_attribute :restricted_size_image, Hyacinth::DigitalObject::TypeDef::Boolean.new

    def initialize
      super
    end
  end
end
