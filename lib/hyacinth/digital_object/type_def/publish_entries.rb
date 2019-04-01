module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishEntries < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(publish_entries)
          return nil if publish_entries.nil?
          [].tap do |arr|
            publish_entries.each do |publish_target_string_key, publish_entry|
              arr << {
                publish_target_string_key => {
                  'published_at' => Hyacinth::DigitalObject::TypeDef::DateTime.to_serialized_form(publish_entry.published_at),
                  'published_by' => Hyacinth::DigitalObject::TypeDef::User.to_serialized_form(publish_entry.published_by)
                }
              }
            end
          end
        end

        def from_serialized_form_impl(json_object)
          return nil if json_object.nil?
          raise ArgumentError, "Expected array, but got: #{json_array.class}" unless json_array.is_a?(Array)
          {}.tap do |hsh|
            json_object.each do |publish_target_string_key, publish_entry_json_object|
              hsh[publish_target_string_key] = Hyacinth::PublishEntry.new(
                published_at: Hyacinth::DigitalObject::TypeDef::DateTime.from_serialized_form(publish_entry_json_object['published_at']),
                published_by: Hyacinth::DigitalObject::TypeDef::User.from_serialized_form(publish_entry_json_object['published_by'])
              )
            end
          end
        end
      end
    end
  end
end
