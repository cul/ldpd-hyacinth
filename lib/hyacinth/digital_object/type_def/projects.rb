module Hyacinth
  module DigitalObject
    module TypeDef
      class Projects < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(projects)
          return nil if projects.nil?
          [].tap do |arr|
            projects.each do |project|
              arr << {
                'string_key' => project.string_key
              }
            end
          end
        end

        def from_serialized_form_impl(json_array)
          return nil if json_array.nil?
          raise ArgumentError, "Expected array, but got: #{json_array.class}" unless json_array.is_a?(Array)
          Set.new.tap do |set|
            json_array.each do |project_json_object|
              set << Project.find_by(string_key: project_json_object['string_key'])
            end
          end
        end
      end
    end
  end
end
