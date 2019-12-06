# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishEntry < Hyacinth::DigitalObject::TypeDef::JsonSerializableHash
        def to_serialized_form_impl(json_object)
          return nil if json_object.nil?
          {
            'published_at' => Hyacinth::DigitalObject::TypeDef::DateTime.new.to_serialized_form(json_object.published_at),
            'published_by' => Hyacinth::DigitalObject::TypeDef::User.new.to_serialized_form(json_object.published_by),
            'cited_at' => Hyacinth::DigitalObject::TypeDef::URI::HTTP.new.to_serialized_form(json_object.cited_at)
          }
        end

        def from_serialized_form_impl(json_object)
          return nil if json_object.nil?
          Hyacinth::PublishEntry.new(
            published_at: Hyacinth::DigitalObject::TypeDef::DateTime.new.from_serialized_form(json_object['published_at']),
            published_by: Hyacinth::DigitalObject::TypeDef::User.new.from_serialized_form(json_object['published_by']),
            cited_at: Hyacinth::DigitalObject::TypeDef::URI::HTTP.new.from_serialized_form(json_object['cited_at'])
          )
        end
      end
    end
  end
end
