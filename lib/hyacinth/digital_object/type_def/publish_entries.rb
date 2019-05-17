module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishEntries < Hyacinth::DigitalObject::TypeDef::JsonSerializableHash
        def to_serialized_form_impl(publish_entries)
          return nil if publish_entries.nil?
          {}.tap do |hsh|
            publish_entries.each do |publish_target_string_key, publish_entry|
              hsh[publish_target_string_key] = {
                'published_at' => Hyacinth::DigitalObject::TypeDef::DateTime.new.to_serialized_form(publish_entry.published_at),
                'published_by' => Hyacinth::DigitalObject::TypeDef::User.new.to_serialized_form(publish_entry.published_by)
              }
            end
          end
        end

        def from_serialized_form_impl(json_object)
          return nil if json_object.nil?
          raise ArgumentError, "Expected hash, but got: #{json_object.class}" unless json_object.is_a?(Hash)
          {}.tap do |hsh|
            json_object.each do |publish_target_string_key, publish_entry_json_object|
              hsh[publish_target_string_key] = Hyacinth::PublishEntry.new(
                published_at: Hyacinth::DigitalObject::TypeDef::DateTime.new.from_serialized_form(publish_entry_json_object['published_at']),
                published_by: Hyacinth::DigitalObject::TypeDef::User.new.from_serialized_form(publish_entry_json_object['published_by'])
              )
            end
          end
        end
      end
    end
  end
end
