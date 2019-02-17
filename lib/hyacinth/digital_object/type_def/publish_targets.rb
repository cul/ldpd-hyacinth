module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishTargets < Hyacinth::DigitalObject::TypeDef::Base
        def to_json_var(publish_targets)
          return nil if publish_targets.nil?
          [].tap do |arr|
            publish_targets.each do |publish_target|
              arr << {
                'string_key' => publish_target.string_key
              }
            end
          end
        end

        def from_json_var(json_array)
          return nil if json_array.nil?
          raise ArgumentError, "Expected array, but got: #{json_array.class}" unless json_array.is_a?(Array)
          [].tap do |arr|
            json_array.each do |publish_target_json_object|
              arr << Project.find_by(string_key: publish_target_json_object['string_key'])
            end
          end
        end
      end
    end
  end
end
